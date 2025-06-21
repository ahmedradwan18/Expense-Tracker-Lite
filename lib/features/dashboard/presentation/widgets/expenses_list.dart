import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/expense.dart';

class ExpensesList extends StatelessWidget {
  final DashboardState state;

  const ExpensesList({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state is DashboardLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is DashboardError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Color(AppConstants.errorColor),
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading expenses',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textPrimaryColor),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              (state as DashboardError).message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(AppConstants.textSecondaryColor),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(const RefreshDashboardData());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      if (loadedState.expenses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64.sp,
                color: Color(AppConstants.textSecondaryColor),
              ),
              SizedBox(height: 16.h),
              Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textPrimaryColor),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Start tracking your expenses by adding your first expense',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(AppConstants.textSecondaryColor),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return AnimatedExpensesList(
        expenses: loadedState.expenses,
        hasMore: loadedState.hasMore,
        isLoadingMore: state is DashboardLoadingMore,
      );
    }

    return const SizedBox.shrink();
  }
}

class AnimatedExpensesList extends StatefulWidget {
  final List<Expense> expenses;
  final bool hasMore;
  final bool isLoadingMore;

  const AnimatedExpensesList({
    super.key,
    required this.expenses,
    required this.hasMore,
    required this.isLoadingMore,
  });

  @override
  State<AnimatedExpensesList> createState() => _AnimatedExpensesListState();
}

class _AnimatedExpensesListState extends State<AnimatedExpensesList>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final List<AnimationController> _itemControllers = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize item controllers
    for (int i = 0; i < widget.expenses.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 100)),
        vsync: this,
      );
      _itemControllers.add(controller);
    }

    // Start staggered animations
    _startStaggeredAnimation();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (widget.hasMore && !widget.isLoadingMore) {
          context.read<DashboardBloc>().add(const LoadMoreExpenses());
        }
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedExpensesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Add controllers for new items
    if (widget.expenses.length > _itemControllers.length) {
      for (int i = _itemControllers.length; i < widget.expenses.length; i++) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
        _itemControllers.add(controller);
        controller.forward();
      }
    }
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.expenses.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.expenses.length) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final expense = widget.expenses[index];
        final animationController = index < _itemControllers.length 
            ? _itemControllers[index] 
            : null;

        if (animationController == null) {
          return _buildExpenseCard(expense);
        }

        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeInOut,
                ),
                child: _buildExpenseCard(expense),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCategoryIcon(expense.category),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense.category,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textPrimaryColor),
                      ),
                    ),
                    Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textPrimaryColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manually',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(AppConstants.textSecondaryColor),
                      ),
                    ),
                    Text(
                      _formatTime(expense.date),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(AppConstants.textSecondaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final categoryData = _getCategoryData(category);
    
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: categoryData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          categoryData['icon'],
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    final categories = {
      'Groceries': {'icon': '🛒', 'color': const Color(0xFF6C7CE7)},
      'Entertainment': {'icon': '🎬', 'color': const Color(0xFF5D67FF)},
      'Transportation': {'icon': '🚗', 'color': const Color(0xFF74C0FC)},
      'Transport': {'icon': '🚗', 'color': const Color(0xFF74C0FC)},
      'Rent': {'icon': '🏠', 'color': const Color(0xFFFFB347)},
      'Food': {'icon': '🍔', 'color': const Color(0xFFFF6B6B)},
      'Shopping': {'icon': '🛍️', 'color': const Color(0xFFFFD93D)},
      'Health': {'icon': '🏥', 'color': const Color(0xFF51CF66)},
      'Education': {'icon': '📚', 'color': const Color(0xFF9775FA)},
      'Gas': {'icon': '⛽', 'color': const Color(0xFFFF6B6B)},
      'News Paper': {'icon': '📰', 'color': const Color(0xFFFFB347)},
      'Others': {'icon': '💰', 'color': const Color(0xFF868E96)},
    };
    
    return categories[category] ?? {'icon': '💰', 'color': const Color(0xFF868E96)};
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(date.year, date.month, date.day);
    
    if (expenseDate == today) {
      return 'Today ${DateFormat('h:mm a').format(date)}';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM dd, h:mm a').format(date);
    }
  }
} 
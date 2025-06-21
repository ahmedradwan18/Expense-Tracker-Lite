import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  const ExpenseCard({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCategoryIcon(),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.textPrimaryColor),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Manually',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(AppConstants.textSecondaryColor),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- \$${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textPrimaryColor),
                ),
              ),
              SizedBox(height: 4.h),
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
    );
  }

  Widget _buildCategoryIcon() {
    final categoryData = _getCategoryData(expense.category);
    
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: categoryData['color'],
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: Text(
          categoryData['emoji'],
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return {
          'emoji': '🛒',
          'color': const Color(0xFF6C7CE7).withOpacity(0.2),
        };
      case 'entertainment':
        return {
          'emoji': '🎬',
          'color': const Color(0xFF5D67FF).withOpacity(0.2),
        };
      case 'gas':
        return {
          'emoji': '⛽',
          'color': const Color(0xFFFF6B6B).withOpacity(0.2),
        };
      case 'shopping':
        return {
          'emoji': '🛍️',
          'color': const Color(0xFFFFD93D).withOpacity(0.2),
        };
      case 'news paper':
        return {
          'emoji': '📰',
          'color': const Color(0xFFFFB347).withOpacity(0.2),
        };
      case 'transport':
      case 'transportation':
        return {
          'emoji': '🚗',
          'color': const Color(0xFF74C0FC).withOpacity(0.2),
        };
      case 'rent':
        return {
          'emoji': '🏠',
          'color': const Color(0xFFFFB347).withOpacity(0.2),
        };
      case 'food':
        return {
          'emoji': '🍔',
          'color': const Color(0xFF4CAF50).withOpacity(0.2),
        };
      case 'health':
        return {
          'emoji': '🏥',
          'color': const Color(0xFF00BCD4).withOpacity(0.2),
        };
      case 'education':
        return {
          'emoji': '📚',
          'color': const Color(0xFF795548).withOpacity(0.2),
        };
      default:
        return {
          'emoji': '💰',
          'color': const Color(0xFF9E9E9E).withOpacity(0.2),
        };
    }
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
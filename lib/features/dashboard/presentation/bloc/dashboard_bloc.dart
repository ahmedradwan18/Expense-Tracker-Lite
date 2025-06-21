import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/export_utils.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/get_expenses.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetExpenses getExpenses;
  final ExpenseRepository expenseRepository;

  DashboardBloc({required this.getExpenses, required this.expenseRepository})
    : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<FilterExpensesByDateRange>(_onFilterExpensesByDateRange);
    on<FilterExpensesByThisMonth>(_onFilterExpensesByThisMonth);
    on<FilterExpensesByLast7Days>(_onFilterExpensesByLast7Days);
    on<ClearFilters>(_onClearFilters);
    on<ChangeFilterSelection>(_onChangeFilterSelection);
    on<ExportToCSV>(_onExportToCSV);
    on<ExportToPDF>(_onExportToPDF);
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is ValidationFailure) return failure.message;
    if (failure is UnknownFailure) return failure.message;
    return 'Unknown error occurred';
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadData(emit, event.startDate, event.endDate, 'This month');
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Preserve current filter if state is loaded
    String currentFilter = 'This month';
    if (state is DashboardLoaded) {
      currentFilter = (state as DashboardLoaded).selectedFilter;
    }

    emit(DashboardLoading());
    await _loadData(emit, event.startDate, event.endDate, currentFilter);
  }

  Future<void> _onChangeFilterSelection(
    ChangeFilterSelection event,
    Emitter<DashboardState> emit,
  ) async {
    print('🔍 Filter changed to: ${event.selectedFilter}');

    // Apply the appropriate filter based on selection
    switch (event.selectedFilter) {
      case 'This month':
        print('🔍 Applying "This month" filter');
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        emit(DashboardLoading());
        await _loadData(emit, startOfMonth, endOfMonth, event.selectedFilter);
        break;
      case 'Last 7 Days':
        print('🔍 Applying "Last 7 Days" filter');
        final now = DateTime.now();
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        emit(DashboardLoading());
        await _loadData(emit, sevenDaysAgo, now, event.selectedFilter);
        break;
      case 'All':
        print('🔍 Clearing all filters');
        emit(DashboardLoading());
        await _loadData(emit, null, null, event.selectedFilter);
        break;
    }
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      if (!currentState.hasMore) return;

      emit(
        DashboardLoadingMore(
          expenses: currentState.expenses,
          totalExpenses: currentState.totalExpenses,
          expensesByCategory: currentState.expensesByCategory,
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
          filterStartDate: currentState.filterStartDate,
          filterEndDate: currentState.filterEndDate,
          selectedFilter: currentState.selectedFilter,
        ),
      );

      final nextPage = currentState.currentPage + 1;
      final result = await getExpenses(
        GetExpensesParams(
          page: nextPage,
          pageSize: AppConstants.itemsPerPage,
          startDate: currentState.filterStartDate,
          endDate: currentState.filterEndDate,
        ),
      );

      result.fold(
        (failure) => emit(DashboardError(_getFailureMessage(failure))),
        (newExpenses) {
          final allExpenses = [...currentState.expenses, ...newExpenses];
          emit(
            currentState.copyWith(
              expenses: allExpenses,
              currentPage: nextPage,
              hasMore: newExpenses.length == AppConstants.itemsPerPage,
            ),
          );
        },
      );
    }
  }

  Future<void> _onFilterExpensesByDateRange(
    FilterExpensesByDateRange event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadData(emit, event.startDate, event.endDate, 'Custom');
  }

  Future<void> _onFilterExpensesByThisMonth(
    FilterExpensesByThisMonth event,
    Emitter<DashboardState> emit,
  ) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    print(
      '🔍 BLoC: Filtering by this month: ${startOfMonth.toString()} to ${endOfMonth.toString()}',
    );

    emit(DashboardLoading());
    await _loadData(emit, startOfMonth, endOfMonth, 'This month');
  }

  Future<void> _onFilterExpensesByLast7Days(
    FilterExpensesByLast7Days event,
    Emitter<DashboardState> emit,
  ) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    print(
      '🔍 BLoC: Filtering by last 7 days: ${sevenDaysAgo.toString()} to ${now.toString()}',
    );

    emit(DashboardLoading());
    await _loadData(emit, sevenDaysAgo, now, 'Last 7 Days');
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<DashboardState> emit,
  ) async {
    print('🔍 BLoC: Clearing all filters');
    emit(DashboardLoading());
    await _loadData(emit, null, null, 'All');
  }

  Future<void> _onExportToCSV(
    ExportToCSV event,
    Emitter<DashboardState> emit,
  ) async {
    // Implementation of exporting to CSV
  }

  Future<void> _onExportToPDF(
    ExportToPDF event,
    Emitter<DashboardState> emit,
  ) async {
    // Implementation of exporting to PDF
  }

  Future<void> _loadData(
    Emitter<DashboardState> emit,
    DateTime? startDate,
    DateTime? endDate,
    String selectedFilter,
  ) async {
    print(
      '🔍 BLoC: Loading data with dates - Start: $startDate, End: $endDate',
    );

    // Load expenses
    final result = await getExpenses(
      GetExpensesParams(
        page: 0,
        pageSize: AppConstants.itemsPerPage,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold((failure) => emit(DashboardError(_getFailureMessage(failure))), (
      expenses,
    ) {
      debugPrint(
        '🔍 BLoC: Loaded ${expenses.length} expenses, total: \$${expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
      );
      debugPrint(
        '🔍 BLoC: Expense dates: ${expenses.map((e) => e.date).join(', ')}',
      );

      // Calculate category totals
      Map<String, double> categoryTotals = {};
      for (var expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      emit(
        DashboardLoaded(
          expenses: expenses,
          totalExpenses: expenses.fold(
            0.0,
            (sum, expense) => sum + expense.amount,
          ),
          expensesByCategory: categoryTotals,
          hasMore: expenses.length >= AppConstants.itemsPerPage,
          currentPage: 0,
          filterStartDate: startDate,
          filterEndDate: endDate,
          selectedFilter: selectedFilter,
        ),
      );
    });
  }
}

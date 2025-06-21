import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Expense> expenses;
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final bool hasMore;
  final int currentPage;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String selectedFilter;

  const DashboardLoaded({
    required this.expenses,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.hasMore,
    required this.currentPage,
    this.filterStartDate,
    this.filterEndDate,
    this.selectedFilter = 'This month',
  });

  @override
  List<Object?> get props => [
        expenses,
        totalExpenses,
        expensesByCategory,
        hasMore,
        currentPage,
        filterStartDate,
        filterEndDate,
        selectedFilter,
      ];

  DashboardLoaded copyWith({
    List<Expense>? expenses,
    double? totalExpenses,
    Map<String, double>? expensesByCategory,
    bool? hasMore,
    int? currentPage,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? selectedFilter,
  }) {
    return DashboardLoaded(
      expenses: expenses ?? this.expenses,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

class ExportLoading extends DashboardState {
  final String exportType; // 'CSV' or 'PDF'

  const ExportLoading(this.exportType);

  @override
  List<Object> get props => [exportType];
}

class ExportSuccess extends DashboardState {
  final String filePath;
  final String fileName;
  final String exportType;

  const ExportSuccess({
    required this.filePath,
    required this.fileName,
    required this.exportType,
  });

  @override
  List<Object> get props => [filePath, fileName, exportType];
}

class ExportError extends DashboardState {
  final String message;
  final String exportType;

  const ExportError({
    required this.message,
    required this.exportType,
  });

  @override
  List<Object> get props => [message, exportType];
}

class DashboardLoadingMore extends DashboardLoaded {
  const DashboardLoadingMore({
    required super.expenses,
    required super.totalExpenses,
    required super.expensesByCategory,
    required super.hasMore,
    required super.currentPage,
    super.filterStartDate,
    super.filterEndDate,
    super.selectedFilter = 'This month',
  });
} 
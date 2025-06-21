import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadDashboardData({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshDashboardData extends DashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshDashboardData({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadMoreExpenses extends DashboardEvent {
  const LoadMoreExpenses();
}

class FilterExpensesByDateRange extends DashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterExpensesByDateRange({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class FilterExpensesByThisMonth extends DashboardEvent {
  const FilterExpensesByThisMonth();
}

class FilterExpensesByLast7Days extends DashboardEvent {
  const FilterExpensesByLast7Days();
}

class ClearFilters extends DashboardEvent {
  const ClearFilters();
}

class ChangeFilterSelection extends DashboardEvent {
  final String selectedFilter;

  const ChangeFilterSelection(this.selectedFilter);

  @override
  List<Object> get props => [selectedFilter];
}

class ExportToCSV extends DashboardEvent {
  const ExportToCSV();
}

class ExportToPDF extends DashboardEvent {
  const ExportToPDF();
} 
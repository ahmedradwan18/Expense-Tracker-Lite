import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<Either<Failure, List<Expense>>> call(GetExpensesParams params) async {
    return await repository.getExpenses(
      page: params.page,
      pageSize: params.pageSize,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetExpensesParams extends Equatable {
  final int page;
  final int pageSize;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetExpensesParams({
    required this.page,
    required this.pageSize,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [page, pageSize, startDate, endDate];
} 
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses({
    int page = 0,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Either<Failure, Expense>> addExpense(Expense expense);
  
  Future<Either<Failure, Expense>> updateExpense(Expense expense);
  
  Future<Either<Failure, bool>> deleteExpense(String id);
  
  Future<Either<Failure, Expense?>> getExpenseById(String id);
  
  Future<Either<Failure, double>> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });
} 
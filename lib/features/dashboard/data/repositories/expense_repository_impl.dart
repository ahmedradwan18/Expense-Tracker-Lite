import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Expense>>> getExpenses({
    int page = 0,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenseModels = await localDataSource.getExpenses(
        page: page,
        pageSize: pageSize,
        startDate: startDate,
        endDate: endDate,
      );
      
      final expenses = expenseModels.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final savedModel = await localDataSource.addExpense(expenseModel);
      return Right(savedModel.toEntity());
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      final updatedModel = await localDataSource.updateExpense(expenseModel);
      return Right(updatedModel.toEntity());
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteExpense(String id) async {
    try {
      final result = await localDataSource.deleteExpense(id);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getExpenseById(String id) async {
    try {
      final expenseModel = await localDataSource.getExpenseById(id);
      final expense = expenseModel?.toEntity();
      return Right(expense);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final total = await localDataSource.getTotalExpenses(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final categoryTotals = await localDataSource.getExpensesByCategory(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(categoryTotals);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
} 
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses({
    int page = 0,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  
  Future<bool> deleteExpense(String id);
  
  Future<ExpenseModel?> getExpenseById(String id);
  
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Map<String, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box<ExpenseModel> expenseBox;

  ExpenseLocalDataSourceImpl({required this.expenseBox});

  @override
  Future<List<ExpenseModel>> getExpenses({
    int page = 0,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<ExpenseModel> expenses = expenseBox.values.toList();
      print('🔍 DataSource: Total expenses in database: ${expenses.length}');
      print('🔍 DataSource: Filter dates - Start: $startDate, End: $endDate');
      
      // Filter by date range if provided
      if (startDate != null || endDate != null) {
        final originalCount = expenses.length;
        expenses = expenses.where((expense) {
          final expenseDate = expense.hiveDate;
          final afterStart = startDate == null || expenseDate.isAfter(startDate) || expenseDate.isAtSameMomentAs(startDate);
          final beforeEnd = endDate == null || expenseDate.isBefore(endDate) || expenseDate.isAtSameMomentAs(endDate);
          return afterStart && beforeEnd;
        }).toList();
        print('🔍 DataSource: After date filtering: ${expenses.length} expenses (was $originalCount)');
      }
      
      // Sort by date (newest first)
      expenses.sort((a, b) => b.hiveDate.compareTo(a.hiveDate));
      
      // Apply pagination
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, expenses.length);
      
      if (startIndex >= expenses.length) {
        print('🔍 DataSource: No expenses for page $page');
        return [];
      }
      
      final result = expenses.sublist(startIndex, endIndex);
      print('🔍 DataSource: Returning ${result.length} expenses for page $page');
      print('🔍 DataSource: Expense dates in result: ${result.map((e) => e.hiveDate.toString()).join(', ')}');
      
      return result;
    } catch (e) {
      print('🔍 DataSource: Error getting expenses: $e');
      throw CacheFailure(message: 'Failed to get expenses: $e');
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      await expenseBox.put(expense.hiveId, expense);
      return expense;
    } catch (e) {
      throw CacheFailure(message: 'Failed to add expense: $e');
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      await expenseBox.put(expense.hiveId, expense);
      return expense;
    } catch (e) {
      throw CacheFailure(message: 'Failed to update expense: $e');
    }
  }

  @override
  Future<bool> deleteExpense(String id) async {
    try {
      await expenseBox.delete(id);
      return true;
    } catch (e) {
      throw CacheFailure(message: 'Failed to delete expense: $e');
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      return expenseBox.get(id);
    } catch (e) {
      throw CacheFailure(message: 'Failed to get expense by id: $e');
    }
  }

  @override
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<ExpenseModel> expenses = expenseBox.values.toList();
      
      // Filter by date range if provided
      if (startDate != null || endDate != null) {
        expenses = expenses.where((expense) {
          final expenseDate = expense.hiveDate;
          final afterStart = startDate == null || expenseDate.isAfter(startDate) || expenseDate.isAtSameMomentAs(startDate);
          final beforeEnd = endDate == null || expenseDate.isBefore(endDate) || expenseDate.isAtSameMomentAs(endDate);
          return afterStart && beforeEnd;
        }).toList();
      }
      
      double total = 0.0;
      for (final expense in expenses) {
        total += expense.hiveAmountInUSD;
      }
      return total;
    } catch (e) {
      throw CacheFailure(message: 'Failed to get total expenses: $e');
    }
  }

  @override
  Future<Map<String, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<ExpenseModel> expenses = expenseBox.values.toList();
      
      // Filter by date range if provided
      if (startDate != null || endDate != null) {
        expenses = expenses.where((expense) {
          final expenseDate = expense.hiveDate;
          final afterStart = startDate == null || expenseDate.isAfter(startDate) || expenseDate.isAtSameMomentAs(startDate);
          final beforeEnd = endDate == null || expenseDate.isBefore(endDate) || expenseDate.isAtSameMomentAs(endDate);
          return afterStart && beforeEnd;
        }).toList();
      }
      
      Map<String, double> categoryTotals = {};
      
      for (final expense in expenses) {
        final category = expense.hiveCategory;
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + expense.hiveAmountInUSD;
      }
      
      return categoryTotals;
    } catch (e) {
      throw CacheFailure(message: 'Failed to get expenses by category: $e');
    }
  }
} 
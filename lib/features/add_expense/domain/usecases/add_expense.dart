import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../dashboard/domain/entities/expense.dart';
import '../../../dashboard/domain/repositories/expense_repository.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<Either<Failure, Expense>> call(AddExpenseParams params) async {
    // Validate the expense data
    final validationResult = _validateExpense(params);
    if (validationResult != null) {
      return Left(ValidationFailure(message: validationResult));
    }

    return await repository.addExpense(params.expense);
  }

  String? _validateExpense(AddExpenseParams params) {
    final expense = params.expense;
    
    if (expense.amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (expense.category.isEmpty) {
      return 'Category is required';
    }
    
    if (expense.currency.isEmpty) {
      return 'Currency is required';
    }
    
    if (expense.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return 'Expense date cannot be in the future';
    }
    
    return null;
  }
}

class AddExpenseParams extends Equatable {
  final Expense expense;

  const AddExpenseParams({required this.expense});

  @override
  List<Object> get props => [expense];
} 
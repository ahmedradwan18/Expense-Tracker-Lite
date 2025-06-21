import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/expense.dart';

abstract class AddExpenseState extends Equatable {
  const AddExpenseState();
  
  @override
  List<Object?> get props => [];
}

class AddExpenseInitial extends AddExpenseState {}

class AddExpenseFormValid extends AddExpenseState {
  final bool isValid;
  
  const AddExpenseFormValid({required this.isValid});
  
  @override
  List<Object> get props => [isValid];
}

class AddExpenseLoading extends AddExpenseState {}

class AddExpenseSuccess extends AddExpenseState {
  final Expense expense;
  
  const AddExpenseSuccess({required this.expense});
  
  @override
  List<Object> get props => [expense];
}

class AddExpenseError extends AddExpenseState {
  final String message;
  
  const AddExpenseError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class CurrencyConversionLoading extends AddExpenseState {}

class CurrencyConversionLoaded extends AddExpenseState {
  final double convertedAmount;
  final String fromCurrency;
  final String toCurrency;
  
  const CurrencyConversionLoaded({
    required this.convertedAmount,
    required this.fromCurrency,
    required this.toCurrency,
  });
  
  @override
  List<Object> get props => [convertedAmount, fromCurrency, toCurrency];
}

class CurrencyConversionError extends AddExpenseState {
  final String message;
  
  const CurrencyConversionError({required this.message});
  
  @override
  List<Object> get props => [message];
} 
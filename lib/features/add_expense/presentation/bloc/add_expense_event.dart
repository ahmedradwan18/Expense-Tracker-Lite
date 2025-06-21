import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AddExpenseEvent extends Equatable {
  const AddExpenseEvent();

  @override
  List<Object?> get props => [];
}

class SubmitExpenseForm extends AddExpenseEvent {
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? description;
  final File? receiptImage;

  const SubmitExpenseForm({
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    this.description,
    this.receiptImage,
  });

  @override
  List<Object?> get props => [
        category,
        amount,
        currency,
        date,
        description,
        receiptImage,
      ];
}

class ValidateExpenseForm extends AddExpenseEvent {
  final String category;
  final double amount;
  final String currency;
  final DateTime date;

  const ValidateExpenseForm({
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
  });

  @override
  List<Object> get props => [category, amount, currency, date];
}

class ConvertCurrency extends AddExpenseEvent {
  final double amount;
  final String fromCurrency;
  final String toCurrency;

  const ConvertCurrency({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object> get props => [amount, fromCurrency, toCurrency];
}

class SelectCategory extends AddExpenseEvent {
  final String category;

  const SelectCategory({required this.category});

  @override
  List<Object> get props => [category];
}

class SelectCurrency extends AddExpenseEvent {
  final String currency;

  const SelectCurrency({required this.currency});

  @override
  List<Object> get props => [currency];
}

class SelectDate extends AddExpenseEvent {
  final DateTime date;

  const SelectDate({required this.date});

  @override
  List<Object> get props => [date];
}

class UploadReceipt extends AddExpenseEvent {
  final String receiptPath;

  const UploadReceipt({required this.receiptPath});

  @override
  List<Object> get props => [receiptPath];
}

class ResetForm extends AddExpenseEvent {
  const ResetForm();
} 
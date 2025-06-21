import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String category;
  final double amount;
  final String currency;
  final double amountInUSD;
  final DateTime date;
  final String? description;
  final String? receiptPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.amountInUSD,
    required this.date,
    this.description,
    this.receiptPath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        amount,
        currency,
        amountInUSD,
        date,
        description,
        receiptPath,
        createdAt,
        updatedAt,
      ];

  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    String? currency,
    double? amountInUSD,
    DateTime? date,
    String? description,
    String? receiptPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountInUSD: amountInUSD ?? this.amountInUSD,
      date: date ?? this.date,
      description: description ?? this.description,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends Expense {
  @HiveField(0)
  final String hiveId;
  
  @HiveField(1)
  final String hiveCategory;
  
  @HiveField(2)
  final double hiveAmount;
  
  @HiveField(3)
  final String hiveCurrency;
  
  @HiveField(4)
  final double hiveAmountInUSD;
  
  @HiveField(5)
  final DateTime hiveDate;
  
  @HiveField(6)
  final String? hiveDescription;
  
  @HiveField(7)
  final String? hiveReceiptPath;
  
  @HiveField(8)
  final DateTime hiveCreatedAt;
  
  @HiveField(9)
  final DateTime hiveUpdatedAt;

  const ExpenseModel({
    required this.hiveId,
    required this.hiveCategory,
    required this.hiveAmount,
    required this.hiveCurrency,
    required this.hiveAmountInUSD,
    required this.hiveDate,
    this.hiveDescription,
    this.hiveReceiptPath,
    required this.hiveCreatedAt,
    required this.hiveUpdatedAt,
  }) : super(
          id: hiveId,
          category: hiveCategory,
          amount: hiveAmount,
          currency: hiveCurrency,
          amountInUSD: hiveAmountInUSD,
          date: hiveDate,
          description: hiveDescription,
          receiptPath: hiveReceiptPath,
          createdAt: hiveCreatedAt,
          updatedAt: hiveUpdatedAt,
        );

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      hiveId: expense.id,
      hiveCategory: expense.category,
      hiveAmount: expense.amount,
      hiveCurrency: expense.currency,
      hiveAmountInUSD: expense.amountInUSD,
      hiveDate: expense.date,
      hiveDescription: expense.description,
      hiveReceiptPath: expense.receiptPath,
      hiveCreatedAt: expense.createdAt,
      hiveUpdatedAt: expense.updatedAt,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      hiveId: json['id'],
      hiveCategory: json['category'],
      hiveAmount: json['amount'].toDouble(),
      hiveCurrency: json['currency'],
      hiveAmountInUSD: json['amountInUSD'].toDouble(),
      hiveDate: DateTime.parse(json['date']),
      hiveDescription: json['description'],
      hiveReceiptPath: json['receiptPath'],
      hiveCreatedAt: DateTime.parse(json['createdAt']),
      hiveUpdatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'category': hiveCategory,
      'amount': hiveAmount,
      'currency': hiveCurrency,
      'amountInUSD': hiveAmountInUSD,
      'date': hiveDate.toIso8601String(),
      'description': hiveDescription,
      'receiptPath': hiveReceiptPath,
      'createdAt': hiveCreatedAt.toIso8601String(),
      'updatedAt': hiveUpdatedAt.toIso8601String(),
    };
  }

  Expense toEntity() {
    return Expense(
      id: hiveId,
      category: hiveCategory,
      amount: hiveAmount,
      currency: hiveCurrency,
      amountInUSD: hiveAmountInUSD,
      date: hiveDate,
      description: hiveDescription,
      receiptPath: hiveReceiptPath,
      createdAt: hiveCreatedAt,
      updatedAt: hiveUpdatedAt,
    );
  }
} 
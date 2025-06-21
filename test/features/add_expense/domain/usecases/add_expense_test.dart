import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/add_expense/domain/usecases/add_expense.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/expense.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/expense_repository.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class FakeExpense extends Fake implements Expense {}

void main() {
  late AddExpense usecase;
  late MockExpenseRepository mockExpenseRepository;
  late Expense testExpense;

  setUpAll(() {
    registerFallbackValue(FakeExpense());
  });

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    usecase = AddExpense(mockExpenseRepository);
    
    testExpense = Expense(
      id: const Uuid().v4(),
      category: 'Food & Dining',
      amount: 25.50,
      currency: 'USD',
      amountInUSD: 25.50,
      date: DateTime.now(),
      description: 'Lunch at restaurant',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('AddExpense', () {
    test('should validate expense and return success when expense is valid', () async {
      // Arrange
      when(() => mockExpenseRepository.addExpense(any()))
          .thenAnswer((_) async => Right(testExpense));

      // Act
      final result = await usecase(AddExpenseParams(expense: testExpense));

      // Assert
      expect(result, Right(testExpense));
      verify(() => mockExpenseRepository.addExpense(testExpense));
    });

    test('should return ValidationFailure when amount is zero or negative', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(amount: 0);

      // Act
      final result = await usecase(AddExpenseParams(expense: invalidExpense));

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verifyNever(() => mockExpenseRepository.addExpense(any()));
    });

    test('should return ValidationFailure when category is empty', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(category: '');

      // Act
      final result = await usecase(AddExpenseParams(expense: invalidExpense));

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verifyNever(() => mockExpenseRepository.addExpense(any()));
    });

    test('should return ValidationFailure when currency is empty', () async {
      // Arrange
      final invalidExpense = testExpense.copyWith(currency: '');

      // Act
      final result = await usecase(AddExpenseParams(expense: invalidExpense));

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verifyNever(() => mockExpenseRepository.addExpense(any()));
    });

    test('should return ValidationFailure when date is in the future', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 2));
      final invalidExpense = testExpense.copyWith(date: futureDate);

      // Act
      final result = await usecase(AddExpenseParams(expense: invalidExpense));

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verifyNever(() => mockExpenseRepository.addExpense(any()));
    });

    test('should return repository failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure(message: 'Cache error');
      when(() => mockExpenseRepository.addExpense(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(AddExpenseParams(expense: testExpense));

      // Assert
      expect(result, const Left(failure));
      verify(() => mockExpenseRepository.addExpense(testExpense));
    });
  });
} 
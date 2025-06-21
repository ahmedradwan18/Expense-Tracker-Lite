import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../../dashboard/domain/entities/expense.dart';
import 'add_expense_event.dart';
import 'add_expense_state.dart';

class AddExpenseBloc extends Bloc<AddExpenseEvent, AddExpenseState> {
  final AddExpense addExpenseUseCase;
  final CurrencyRepository currencyRepository;

  AddExpenseBloc({
    required this.addExpenseUseCase,
    required this.currencyRepository,
  }) : super(AddExpenseInitial()) {
    on<SubmitExpenseForm>(_onSubmitExpenseForm);
    on<ValidateExpenseForm>(_onValidateExpenseForm);
    on<ConvertCurrency>(_onConvertCurrency);
    on<ResetForm>(_onResetForm);
  }

  Future<void> _onSubmitExpenseForm(
    SubmitExpenseForm event,
    Emitter<AddExpenseState> emit,
  ) async {
    emit(AddExpenseLoading());
    
    try {
      // First convert currency to USD if needed
      double amountInUSD = event.amount;
      if (event.currency != 'USD') {
        print('🔄 Converting ${event.amount} ${event.currency} to USD for saving...');
        final conversionResult = await currencyRepository.convertCurrency(
          amount: event.amount,
          fromCurrency: event.currency,
          toCurrency: 'USD',
        );
        
        final convertedAmount = conversionResult.fold(
          (failure) {
            print('❌ Currency conversion failed: $failure');
            emit(AddExpenseError(message: 'Currency conversion failed: ${failure.toString()}'));
            return null;
          },
          (convertedAmount) {
            print('✅ Conversion successful: ${event.amount} ${event.currency} = \$${convertedAmount.toStringAsFixed(2)} USD');
            return convertedAmount;
          },
        );
        
        if (convertedAmount == null) return; // Error already emitted
        amountInUSD = convertedAmount;
      }
      
      // Create expense entity
      final expense = Expense(
        id: const Uuid().v4(),
        category: event.category,
        amount: event.amount,
        currency: event.currency,
        amountInUSD: amountInUSD,
        date: event.date,
        description: event.description,
        receiptPath: event.receiptImage?.path,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('💾 Saving expense: ${expense.amount} ${expense.currency} (USD: \$${expense.amountInUSD.toStringAsFixed(2)})');
      
      // Save expense
      final result = await addExpenseUseCase(AddExpenseParams(expense: expense));
      
      result.fold(
        (failure) {
          print('❌ Failed to save expense: $failure');
          emit(AddExpenseError(message: failure.toString()));
        },
        (savedExpense) {
          print('✅ Expense saved successfully!');
          emit(AddExpenseSuccess(expense: savedExpense));
        },
      );
    } catch (e) {
      print('💥 Exception in submit expense: $e');
      emit(AddExpenseError(message: e.toString()));
    }
  }

  Future<void> _onValidateExpenseForm(
    ValidateExpenseForm event,
    Emitter<AddExpenseState> emit,
  ) async {
    final isValid = _validateForm(event);
    emit(AddExpenseFormValid(isValid: isValid));
  }

  Future<void> _onConvertCurrency(
    ConvertCurrency event,
    Emitter<AddExpenseState> emit,
  ) async {
    print('🔄 Live conversion: ${event.amount} ${event.fromCurrency} to ${event.toCurrency}');
    emit(CurrencyConversionLoading());
    
    try {
      final result = await currencyRepository.convertCurrency(
        amount: event.amount,
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
      );
      
      result.fold(
        (failure) {
          print('❌ Live conversion failed: $failure');
          emit(CurrencyConversionError(message: failure.toString()));
        },
        (convertedAmount) {
          print('✅ Live conversion successful: ${event.amount} ${event.fromCurrency} = \$${convertedAmount.toStringAsFixed(2)} ${event.toCurrency}');
          emit(CurrencyConversionLoaded(
            convertedAmount: convertedAmount,
            fromCurrency: event.fromCurrency,
            toCurrency: event.toCurrency,
          ));
        },
      );
    } catch (e) {
      print('💥 Exception in live conversion: $e');
      emit(CurrencyConversionError(message: e.toString()));
    }
  }

  void _onResetForm(ResetForm event, Emitter<AddExpenseState> emit) {
    emit(AddExpenseInitial());
  }

  bool _validateForm(ValidateExpenseForm event) {
    return event.amount > 0 &&
           event.category.isNotEmpty &&
           event.currency.isNotEmpty &&
           event.date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }
} 
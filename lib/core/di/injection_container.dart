import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../network/network_info.dart';
import '../../features/dashboard/data/datasources/expense_local_data_source.dart';
import '../../features/dashboard/data/models/expense_model.dart';
import '../../features/dashboard/data/repositories/expense_repository_impl.dart';
import '../../features/dashboard/domain/repositories/expense_repository.dart';
import '../../features/dashboard/domain/usecases/get_expenses.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/add_expense/data/datasources/currency_local_data_source.dart';
import '../../features/add_expense/data/datasources/currency_remote_data_source.dart';
import '../../features/add_expense/data/models/exchange_rate_model.dart';
import '../../features/add_expense/data/repositories/currency_repository_impl.dart';
import '../../features/add_expense/domain/repositories/currency_repository.dart';
import '../../features/add_expense/domain/usecases/add_expense.dart';
import '../../features/add_expense/presentation/bloc/add_expense_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register Hive adapters
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(ExchangeRateModelAdapter());
  
  // Open Hive boxes
  final expenseBox = await Hive.openBox<ExpenseModel>(AppConstants.expenseBoxName);
  final currencyBox = await Hive.openBox<ExchangeRateModel>(AppConstants.currencyBoxName);

  // External dependencies
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Hive boxes
  sl.registerSingleton<Box<ExpenseModel>>(expenseBox);
  sl.registerSingleton<Box<ExchangeRateModel>>(currencyBox);

  // Data sources
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(expenseBox: sl()),
  );
  sl.registerLazySingleton<CurrencyLocalDataSource>(
    () => CurrencyLocalDataSourceImpl(currencyBox: sl()),
  );
  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));

  // BLoCs - Register as factory to get new instances each time
  sl.registerFactory(() => DashboardBloc(
    getExpenses: sl(),
    expenseRepository: sl(),
  ));
  sl.registerFactory(() => AddExpenseBloc(
    addExpenseUseCase: sl(),
    currencyRepository: sl(),
  ));
} 
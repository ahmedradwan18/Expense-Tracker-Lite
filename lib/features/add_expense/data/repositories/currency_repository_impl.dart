import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_local_data_source.dart';
import '../datasources/currency_remote_data_source.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;
  final CurrencyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ExchangeRate>> getExchangeRates() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteExchangeRates = await remoteDataSource.getExchangeRates();
        await localDataSource.cacheExchangeRates(remoteExchangeRates);
        return Right(remoteExchangeRates.toEntity());
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      try {
        final cachedExchangeRates = await localDataSource.getCachedExchangeRates();
        if (cachedExchangeRates != null) {
          return Right(cachedExchangeRates.toEntity());
        } else {
          return Left(CacheFailure(message: 'No cached exchange rates available'));
        }
      } on CacheFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ExchangeRate>> getCachedExchangeRates() async {
    try {
      final cachedExchangeRates = await localDataSource.getCachedExchangeRates();
      if (cachedExchangeRates != null) {
        return Right(cachedExchangeRates.toEntity());
      } else {
        return Left(CacheFailure(message: 'No cached exchange rates available'));
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final exchangeRatesResult = await getExchangeRates();
      
      return exchangeRatesResult.fold(
        (failure) => Left(failure),
        (exchangeRates) {
          final convertedAmount = exchangeRates.convertAmount(
            amount: amount,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
          );
          return Right(convertedAmount);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSupportedCurrencies() async {
    try {
      return Right(AppConstants.supportedCurrencies);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
} 
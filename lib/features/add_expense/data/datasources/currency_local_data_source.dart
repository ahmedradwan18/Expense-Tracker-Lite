import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../models/exchange_rate_model.dart';

abstract class CurrencyLocalDataSource {
  Future<ExchangeRateModel?> getCachedExchangeRates();
  Future<void> cacheExchangeRates(ExchangeRateModel exchangeRates);
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  final Box<ExchangeRateModel> currencyBox;

  CurrencyLocalDataSourceImpl({required this.currencyBox});

  @override
  Future<ExchangeRateModel?> getCachedExchangeRates() async {
    try {
      return currencyBox.get('latest_rates');
    } catch (e) {
      throw CacheFailure(message: 'Failed to get cached exchange rates: $e');
    }
  }

  @override
  Future<void> cacheExchangeRates(ExchangeRateModel exchangeRates) async {
    try {
      await currencyBox.put('latest_rates', exchangeRates);
    } catch (e) {
      throw CacheFailure(message: 'Failed to cache exchange rates: $e');
    }
  }
} 
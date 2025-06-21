import 'package:equatable/equatable.dart';

class ExchangeRate extends Equatable {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  const ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  double? getRateFor(String currency) {
    return rates[currency];
  }

  double convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;
    
    // Convert from base currency to target currency
    if (fromCurrency == baseCurrency) {
      final rate = rates[toCurrency];
      return rate != null ? amount * rate : amount;
    }
    
    // Convert to base currency first, then to target currency
    final fromRate = rates[fromCurrency];
    if (fromRate == null) return amount;
    
    final amountInBase = amount / fromRate;
    
    if (toCurrency == baseCurrency) return amountInBase;
    
    final toRate = rates[toCurrency];
    return toRate != null ? amountInBase * toRate : amount;
  }

  @override
  List<Object?> get props => [baseCurrency, rates, lastUpdated];

  ExchangeRate copyWith({
    String? baseCurrency,
    Map<String, double>? rates,
    DateTime? lastUpdated,
  }) {
    return ExchangeRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      rates: rates ?? this.rates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
} 
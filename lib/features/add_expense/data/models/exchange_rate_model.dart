import 'package:hive/hive.dart';
import '../../domain/entities/exchange_rate.dart';

part 'exchange_rate_model.g.dart';

@HiveType(typeId: 1)
class ExchangeRateModel extends ExchangeRate {
  @HiveField(0)
  final String hiveBaseCurrency;
  
  @HiveField(1)
  final Map<String, double> hiveRates;
  
  @HiveField(2)
  final DateTime hiveLastUpdated;

  const ExchangeRateModel({
    required this.hiveBaseCurrency,
    required this.hiveRates,
    required this.hiveLastUpdated,
  }) : super(
          baseCurrency: hiveBaseCurrency,
          rates: hiveRates,
          lastUpdated: hiveLastUpdated,
        );

  factory ExchangeRateModel.fromEntity(ExchangeRate exchangeRate) {
    return ExchangeRateModel(
      hiveBaseCurrency: exchangeRate.baseCurrency,
      hiveRates: exchangeRate.rates,
      hiveLastUpdated: exchangeRate.lastUpdated,
    );
  }

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    print('📨 API Response: ${json.keys}'); // Debug log
    
    final conversionRates = json['conversion_rates'] as Map<String, dynamic>? ?? {};
    final rates = <String, double>{};
    
    for (final entry in conversionRates.entries) {
      rates[entry.key] = (entry.value as num).toDouble();
    }
    
    return ExchangeRateModel(
      hiveBaseCurrency: json['base_code'] ?? 'USD',
      hiveRates: rates,
      hiveLastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_code': hiveBaseCurrency,
      'conversion_rates': hiveRates,
      'last_updated': hiveLastUpdated.toIso8601String(),
    };
  }

  ExchangeRate toEntity() {
    return ExchangeRate(
      baseCurrency: hiveBaseCurrency,
      rates: hiveRates,
      lastUpdated: hiveLastUpdated,
    );
  }
} 
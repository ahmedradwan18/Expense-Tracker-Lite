import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../models/exchange_rate_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<ExchangeRateModel> getExchangeRates();
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final http.Client client;

  CurrencyRemoteDataSourceImpl({required this.client});

  @override
  Future<ExchangeRateModel> getExchangeRates() async {
    try {
      print('🌐 Making API call to: ${AppConstants.currencyApiUrl}');
      final response = await client.get(
        Uri.parse(AppConstants.currencyApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📊 API Response Status: ${response.statusCode}');
      print('📊 API Response Body: ${response.body.substring(0, 200)}...'); // First 200 chars

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final model = ExchangeRateModel.fromJson(jsonData);
        print('✅ Successfully parsed ${model.hiveRates.length} exchange rates');
        return model;
      } else {
        throw ServerFailure(
          message: 'Failed to fetch exchange rates: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure(message: 'Network error: $e');
    }
  }
} 
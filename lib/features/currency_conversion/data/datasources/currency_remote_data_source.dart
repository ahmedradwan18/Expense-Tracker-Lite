import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../add_expense/data/models/exchange_rate_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<ExchangeRateModel> getExchangeRates();
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final http.Client client;

  CurrencyRemoteDataSourceImpl({required this.client});

  @override
  Future<ExchangeRateModel> getExchangeRates() async {
    try {
      final response = await client.get(
        Uri.parse(AppConstants.currencyApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ExchangeRateModel.fromJson(jsonData);
      } else {
        throw ServerFailure(
          message: 'Failed to fetch exchange rates: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure(message: 'Network error: $e');
    }
  }
} 
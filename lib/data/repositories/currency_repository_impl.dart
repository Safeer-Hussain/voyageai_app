import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/local_storage_datasource.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final LocalStorageDatasource _datasource;
  final SharedPreferences _prefs;

  static const String _prefPrefix = 'voyage_custom_rate_';

  CurrencyRepositoryImpl(this._datasource, this._prefs);

  @override
  Future<Map<String, double>> getExchangeRates() async {
    final Map<String, double> rates = Map.from(AppConstants.usdExchangeRates);

    // Support additional major travel currencies
    rates.putIfAbsent('GBP', () => 0.79);
    rates.putIfAbsent('CHF', () => 0.90);
    rates.putIfAbsent('CAD', () => 1.39);
    rates.putIfAbsent('AUD', () => 1.54);

    for (final code in rates.keys.toList()) {
      final customRate = _prefs.getDouble('$_prefPrefix$code');
      if (customRate != null && customRate > 0) {
        rates[code] = customRate;
      }
    }

    return rates;
  }

  @override
  Future<void> updateCustomRate(String currencyCode, double rateToUsd) async {
    await _prefs.setDouble('$_prefPrefix$currencyCode', rateToUsd);
  }

  @override
  Future<void> resetRates() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedConversions() async {
    return await _datasource.getSavedCurrencyConversions();
  }

  @override
  Future<void> saveConversion(
    String base,
    String target,
    double baseAmount,
    double convertedAmount,
  ) async {
    await _datasource.insertCurrencyConversion(
      base,
      target,
      baseAmount,
      convertedAmount,
    );
  }

  @override
  Future<void> deleteConversion(int id) async {
    await _datasource.deleteCurrencyConversion(id);
  }
}

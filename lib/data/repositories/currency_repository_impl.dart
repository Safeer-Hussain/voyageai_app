import '../../core/constants/app_constants.dart';
import '../../domain/entities/currency_cheat_sheet.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/currency_rate_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final LocalStorageDatasource _datasource;

  CurrencyRepositoryImpl(this._datasource);

  @override
  Future<List<CurrencyRate>> getStoredRates() async {
    return await _datasource.getStoredCurrencyRates();
  }

  @override
  Future<CurrencyRate?> getRate(String base, String target) async {
    final fromDb = await _datasource.getCurrencyRate(base, target);
    if (fromDb != null) return fromDb;

    // Calculate cross-currency rate using AppConstants.usdExchangeRates
    final baseToUsd = AppConstants.usdExchangeRates[base] ?? 1.0;
    final targetToUsd = AppConstants.usdExchangeRates[target] ?? 1.0;
    final calculatedRate = targetToUsd / baseToUsd;

    final rateEntity = CurrencyRate(
      baseCurrency: base,
      targetCurrency: target,
      rate: calculatedRate,
      spreadPercent: 0.0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await saveRate(rateEntity);
    return rateEntity;
  }

  @override
  Future<void> saveRate(CurrencyRate rate) async {
    final model = CurrencyRateModel.fromEntity(rate);
    await _datasource.insertCurrencyRate(model);
  }

  @override
  Future<void> updateSpread(
    String base,
    String target,
    double spreadPercent,
  ) async {
    await _datasource.updateCurrencySpread(base, target, spreadPercent);
  }
}

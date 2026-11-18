import '../entities/currency_cheat_sheet.dart';

abstract class CurrencyRepository {
  Future<List<CurrencyRate>> getStoredRates();
  Future<CurrencyRate?> getRate(String base, String target);
  Future<void> saveRate(CurrencyRate rate);
  Future<void> updateSpread(String base, String target, double spreadPercent);
}

abstract class CurrencyRepository {
  Future<Map<String, double>> getExchangeRates();
  Future<void> updateCustomRate(String currencyCode, double rateToUsd);
  Future<void> resetRates();
  Future<List<Map<String, dynamic>>> getSavedConversions();
  Future<void> saveConversion(
    String base,
    String target,
    double baseAmount,
    double convertedAmount,
  );
  Future<void> deleteConversion(int id);
}

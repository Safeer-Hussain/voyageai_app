import '../../domain/entities/currency_cheat_sheet.dart';

class CurrencyRateModel extends CurrencyRate {
  const CurrencyRateModel({
    required super.baseCurrency,
    required super.targetCurrency,
    required super.rate,
    super.spreadPercent,
    required super.updatedAt,
  });

  factory CurrencyRateModel.fromEntity(CurrencyRate rate) {
    return CurrencyRateModel(
      baseCurrency: rate.baseCurrency,
      targetCurrency: rate.targetCurrency,
      rate: rate.rate,
      spreadPercent: rate.spreadPercent,
      updatedAt: rate.updatedAt,
    );
  }

  factory CurrencyRateModel.fromMap(Map<String, dynamic> map) {
    final entity = CurrencyRate.fromMap(map);
    return CurrencyRateModel.fromEntity(entity);
  }
}

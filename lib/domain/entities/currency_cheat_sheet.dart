class CurrencyRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final double spreadPercent;
  final int updatedAt;

  const CurrencyRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    this.spreadPercent = 0.0,
    required this.updatedAt,
  });

  double get effectiveRate => rate * (1 + spreadPercent / 100);

  double convert(double amount) => amount * effectiveRate;

  double convertInverse(double amount) {
    if (effectiveRate <= 0) return 0.0;
    return amount / effectiveRate;
  }

  CurrencyRate copyWith({
    String? baseCurrency,
    String? targetCurrency,
    double? rate,
    double? spreadPercent,
    int? updatedAt,
  }) {
    return CurrencyRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      spreadPercent: spreadPercent ?? this.spreadPercent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': '${baseCurrency}_$targetCurrency',
      'base_currency': baseCurrency,
      'target_currency': targetCurrency,
      'rate': rate,
      'spread_percent': spreadPercent,
      'updated_at': updatedAt,
    };
  }

  factory CurrencyRate.fromMap(Map<String, dynamic> map) {
    return CurrencyRate(
      baseCurrency: map['base_currency'] as String? ?? 'USD',
      targetCurrency: map['target_currency'] as String? ?? 'PKR',
      rate: (map['rate'] as num?)?.toDouble() ?? 1.0,
      spreadPercent: (map['spread_percent'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
    );
  }
}

class CheatSheetDenomination {
  final double baseAmount;
  final double convertedAmount;
  final String formattedBase;
  final String formattedConverted;

  const CheatSheetDenomination({
    required this.baseAmount,
    required this.convertedAmount,
    required this.formattedBase,
    required this.formattedConverted,
  });
}

class MerchantTipPreset {
  final String category;
  final String title;
  final double defaultTipPercentage;
  final String etiquetteNotice;

  const MerchantTipPreset({
    required this.category,
    required this.title,
    required this.defaultTipPercentage,
    required this.etiquetteNotice,
  });
}

class TipCalculation {
  final double billAmount;
  final double tipPercentage;
  final double tipAmount;
  final double totalWithTip;
  final int splitCount;
  final double perPersonBill;
  final double perPersonTip;
  final double perPersonTotal;
  final double roundedTotal;
  final double roundUpDifference;

  const TipCalculation({
    required this.billAmount,
    required this.tipPercentage,
    required this.tipAmount,
    required this.totalWithTip,
    required this.splitCount,
    required this.perPersonBill,
    required this.perPersonTip,
    required this.perPersonTotal,
    required this.roundedTotal,
    required this.roundUpDifference,
  });
}

class CurrencyRate {
  final String code;
  final String name;
  final String symbol;
  final double rateToUsd;
  final bool isCustom;

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateToUsd,
    this.isCustom = false,
  });

  CurrencyRate copyWith({
    String? code,
    String? name,
    String? symbol,
    double? rateToUsd,
    bool? isCustom,
  }) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      rateToUsd: rateToUsd ?? this.rateToUsd,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'rate_to_usd': rateToUsd,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory CurrencyRate.fromMap(Map<String, dynamic> map) {
    return CurrencyRate(
      code: map['code'] as String? ?? 'USD',
      name: map['name'] as String? ?? 'US Dollar',
      symbol: map['symbol'] as String? ?? '\$',
      rateToUsd: (map['rate_to_usd'] as num?)?.toDouble() ?? 1.0,
      isCustom: map['is_custom'] == 1 || map['is_custom'] == true,
    );
  }
}

class CheatSheetRow {
  final double baseAmount;
  final double convertedAmount;
  final String formattedBase;
  final String formattedConverted;

  const CheatSheetRow({
    required this.baseAmount,
    required this.convertedAmount,
    required this.formattedBase,
    required this.formattedConverted,
  });
}

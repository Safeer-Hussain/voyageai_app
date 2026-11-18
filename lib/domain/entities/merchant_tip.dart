enum MerchantType { dining, taxi, porter, tourGuide, cafe }

enum RoundingMode { exact, roundUpTotal, roundUpPerPerson }

class TipCalculationResult {
  final double billAmount;
  final double tipPercentage;
  final double tipAmount;
  final double totalAmount;
  final int splitCount;
  final double perPersonBill;
  final double perPersonTip;
  final double perPersonTotal;
  final RoundingMode roundingMode;
  final String currencyCode;
  final double equivalentBaseTotal;
  final String baseCurrencyCode;

  const TipCalculationResult({
    required this.billAmount,
    required this.tipPercentage,
    required this.tipAmount,
    required this.totalAmount,
    required this.splitCount,
    required this.perPersonBill,
    required this.perPersonTip,
    required this.perPersonTotal,
    required this.roundingMode,
    required this.currencyCode,
    required this.equivalentBaseTotal,
    required this.baseCurrencyCode,
  });
}

class TippingEtiquette {
  final String countryOrCurrency;
  final String generalGuidance;
  final double recommendedDiningPct;
  final double recommendedTaxiPct;
  final double recommendedPorterAmount;
  final double recommendedGuidePct;
  final bool isTippingCustomary;

  const TippingEtiquette({
    required this.countryOrCurrency,
    required this.generalGuidance,
    required this.recommendedDiningPct,
    required this.recommendedTaxiPct,
    required this.recommendedPorterAmount,
    required this.recommendedGuidePct,
    required this.isTippingCustomary,
  });
}

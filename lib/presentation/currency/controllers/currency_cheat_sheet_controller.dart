import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/currency_rate.dart';
import '../../../domain/entities/merchant_tip.dart';
import '../../../domain/repositories/currency_repository.dart';

class CurrencyCheatSheetController extends GetxController {
  final CurrencyRepository _repository;

  CurrencyCheatSheetController(this._repository);

  final RxMap<String, double> rates = <String, double>{}.obs;
  final RxString baseCurrency = 'USD'.obs;
  final RxString targetCurrency = 'PKR'.obs;
  final RxDouble billAmount = 2500.0.obs;
  final Rx<MerchantType> merchantType = MerchantType.dining.obs;
  final RxDouble tipPercentage = 10.0.obs;
  final RxInt splitCount = 1.obs;
  final Rx<RoundingMode> roundingMode = RoundingMode.exact.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> savedConversions =
      <Map<String, dynamic>>[].obs;

  static const List<String> availableCurrencies = [
    'USD',
    'PKR',
    'EUR',
    'JPY',
    'AED',
    'GBP',
    'CHF',
    'CAD',
    'AUD',
  ];

  static const List<double> standardDenominations = [
    1.0,
    5.0,
    10.0,
    20.0,
    50.0,
    100.0,
    250.0,
    500.0,
    1000.0,
  ];

  @override
  void onInit() {
    super.onInit();
    loadRates();
    loadSavedConversions();
  }

  Future<void> loadRates() async {
    isLoading.value = true;
    try {
      final loadedRates = await _repository.getExchangeRates();
      rates.assignAll(loadedRates);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSavedConversions() async {
    final list = await _repository.getSavedConversions();
    savedConversions.assignAll(list);
  }

  double get directExchangeRate {
    final baseToUsd = rates[baseCurrency.value] ?? 1.0;
    final targetToUsd = rates[targetCurrency.value] ?? 1.0;
    if (baseToUsd <= 0) return 1.0;
    return targetToUsd / baseToUsd;
  }

  double get inverseExchangeRate {
    final rate = directExchangeRate;
    if (rate <= 0) return 1.0;
    return 1.0 / rate;
  }

  double convert(double amount, String from, String to) {
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    if (fromRate <= 0) return amount;
    final amountInUsd = amount / fromRate;
    return amountInUsd * toRate;
  }

  List<CheatSheetRow> get cheatSheetRows {
    final rate = directExchangeRate;
    return standardDenominations.map((denom) {
      final converted = denom * rate;
      return CheatSheetRow(
        baseAmount: denom,
        convertedAmount: converted,
        formattedBase: '${denom.toStringAsFixed(0)} ${baseCurrency.value}',
        formattedConverted:
            '${formatAmount(converted)} ${targetCurrency.value}',
      );
    }).toList();
  }

  List<CheatSheetRow> get inverseCheatSheetRows {
    final rate = inverseExchangeRate;
    return standardDenominations.map((denom) {
      final converted = denom * rate;
      return CheatSheetRow(
        baseAmount: denom,
        convertedAmount: converted,
        formattedBase: '${denom.toStringAsFixed(0)} ${targetCurrency.value}',
        formattedConverted: '${formatAmount(converted)} ${baseCurrency.value}',
      );
    }).toList();
  }

  TipCalculationResult get tipCalculation {
    final bill = billAmount.value;
    final tipPct = tipPercentage.value;
    final rawTip = bill * (tipPct / 100.0);
    double total = bill + rawTip;
    final splits = splitCount.value.clamp(1, 20);

    double perPersonTotal = total / splits;
    double perPersonTip = rawTip / splits;
    double perPersonBill = bill / splits;

    if (roundingMode.value == RoundingMode.roundUpTotal) {
      total = total.ceilToDouble();
      perPersonTotal = total / splits;
    } else if (roundingMode.value == RoundingMode.roundUpPerPerson) {
      perPersonTotal = perPersonTotal.ceilToDouble();
      total = perPersonTotal * splits;
    }

    final equivalentBase = convert(
      total,
      targetCurrency.value,
      baseCurrency.value,
    );

    return TipCalculationResult(
      billAmount: bill,
      tipPercentage: tipPct,
      tipAmount: rawTip,
      totalAmount: total,
      splitCount: splits,
      perPersonBill: perPersonBill,
      perPersonTip: perPersonTip,
      perPersonTotal: perPersonTotal,
      roundingMode: roundingMode.value,
      currencyCode: targetCurrency.value,
      equivalentBaseTotal: equivalentBase,
      baseCurrencyCode: baseCurrency.value,
    );
  }

  TippingEtiquette get tippingEtiquette {
    final cur = targetCurrency.value;
    switch (cur) {
      case 'JPY':
        return const TippingEtiquette(
          countryOrCurrency: 'Japan (JPY)',
          generalGuidance: 'Tipping is not customary in Japan. Good service is standard practice and included. Leaving extra cash can cause confusion.',
          recommendedDiningPct: 0.0,
          recommendedTaxiPct: 0.0,
          recommendedPorterAmount: 0.0,
          recommendedGuidePct: 0.0,
          isTippingCustomary: false,
        );
      case 'PKR':
        return const TippingEtiquette(
          countryOrCurrency: 'Pakistan (PKR)',
          generalGuidance: 'Tipping 5% to 10% is customary in sit-down restaurants and tea houses. Cash gratuities for porters and drivers are appreciated.',
          recommendedDiningPct: 10.0,
          recommendedTaxiPct: 5.0,
          recommendedPorterAmount: 200.0,
          recommendedGuidePct: 10.0,
          isTippingCustomary: true,
        );
      case 'EUR':
        return const TippingEtiquette(
          countryOrCurrency: 'Eurozone (EUR)',
          generalGuidance: 'Service is typically included (service compris). Rounding up the bill or leaving 5% to 10% cash for attentive service is customary.',
          recommendedDiningPct: 7.5,
          recommendedTaxiPct: 5.0,
          recommendedPorterAmount: 2.0,
          recommendedGuidePct: 10.0,
          isTippingCustomary: true,
        );
      case 'AED':
        return const TippingEtiquette(
          countryOrCurrency: 'UAE (AED)',
          generalGuidance: '10% to 15% is standard practice in restaurants. For taxis, round up to the nearest 5 or 10 AED note.',
          recommendedDiningPct: 12.0,
          recommendedTaxiPct: 5.0,
          recommendedPorterAmount: 10.0,
          recommendedGuidePct: 10.0,
          isTippingCustomary: true,
        );
      case 'GBP':
        return const TippingEtiquette(
          countryOrCurrency: 'United Kingdom (GBP)',
          generalGuidance: '10% to 12.5% is standard for dining if not already added as a discretionary service charge on the receipt.',
          recommendedDiningPct: 12.5,
          recommendedTaxiPct: 10.0,
          recommendedPorterAmount: 2.0,
          recommendedGuidePct: 10.0,
          isTippingCustomary: true,
        );
      case 'CHF':
        return const TippingEtiquette(
          countryOrCurrency: 'Switzerland (CHF)',
          generalGuidance: 'Service charges are included in food and beverage prices by federal law. Rounding up to the nearest franc is common.',
          recommendedDiningPct: 5.0,
          recommendedTaxiPct: 0.0,
          recommendedPorterAmount: 3.0,
          recommendedGuidePct: 5.0,
          isTippingCustomary: false,
        );
      default: // USD and others
        return const TippingEtiquette(
          countryOrCurrency: 'United States & Global Standard',
          generalGuidance: '15% to 20% is customary for sit-down dining. \$2 to \$5 per bag for hotel luggage porters. 10% to 15% for taxi drivers.',
          recommendedDiningPct: 18.0,
          recommendedTaxiPct: 15.0,
          recommendedPorterAmount: 3.0,
          recommendedGuidePct: 15.0,
          isTippingCustomary: true,
        );
    }
  }

  void swapCurrencies() {
    final temp = baseCurrency.value;
    baseCurrency.value = targetCurrency.value;
    targetCurrency.value = temp;
  }

  void setBaseCurrency(String code) {
    if (code == targetCurrency.value) {
      swapCurrencies();
    } else {
      baseCurrency.value = code;
    }
  }

  void setTargetCurrency(String code) {
    if (code == baseCurrency.value) {
      swapCurrencies();
    } else {
      targetCurrency.value = code;
    }
  }

  void setBillAmount(double val) {
    billAmount.value = val.clamp(0.0, 10000000.0);
  }

  void setTipPercentage(double pct) {
    tipPercentage.value = pct.clamp(0.0, 50.0);
  }

  void setMerchantType(MerchantType type) {
    merchantType.value = type;
    final etiquette = tippingEtiquette;
    switch (type) {
      case MerchantType.dining:
        tipPercentage.value = etiquette.recommendedDiningPct;
        break;
      case MerchantType.taxi:
        tipPercentage.value = etiquette.recommendedTaxiPct;
        break;
      case MerchantType.porter:
        tipPercentage.value = 5.0;
        break;
      case MerchantType.tourGuide:
        tipPercentage.value = etiquette.recommendedGuidePct;
        break;
      case MerchantType.cafe:
        tipPercentage.value = etiquette.isTippingCustomary ? 5.0 : 0.0;
        break;
    }
  }

  void setSplitCount(int count) {
    splitCount.value = count.clamp(1, 20);
  }

  void incrementSplit() {
    if (splitCount.value < 20) splitCount.value++;
  }

  void decrementSplit() {
    if (splitCount.value > 1) splitCount.value--;
  }

  void setRoundingMode(RoundingMode mode) {
    roundingMode.value = mode;
  }

  Future<void> updateCustomRate(double newRateToUsd) async {
    rates[targetCurrency.value] = newRateToUsd;
    await _repository.updateCustomRate(targetCurrency.value, newRateToUsd);
    rates.refresh();

    AppFeedback.showSuccess(
      title: 'Exchange Rate Updated',
      message:
          '1 USD = $newRateToUsd ${targetCurrency.value} calibrated successfully.',
    );
  }

  Future<void> resetRates() async {
    await _repository.resetRates();
    await loadRates();

    AppFeedback.showInfo(
      title: 'Rates Reset',
      message: 'Official reference exchange rates restored.',
    );
  }

  Future<void> saveCurrentConversion() async {
    final calc = tipCalculation;
    await _repository.saveConversion(
      targetCurrency.value,
      baseCurrency.value,
      calc.totalAmount,
      calc.equivalentBaseTotal,
    );
    await loadSavedConversions();

    AppFeedback.showSuccess(
      title: 'Conversion Saved',
      message:
          '${formatAmount(calc.totalAmount)} ${targetCurrency.value} saved to vault ledger.',
    );
  }

  Future<void> deleteSavedConversion(int id) async {
    await _repository.deleteConversion(id);
    await loadSavedConversions();

    AppFeedback.showInfo(
      title: 'Entry Removed',
      message: 'Saved conversion deleted from history.',
    );
  }

  String formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(1);
    } else if (amount >= 1) {
      return amount.toStringAsFixed(2);
    } else {
      return amount.toStringAsFixed(3);
    }
  }
}

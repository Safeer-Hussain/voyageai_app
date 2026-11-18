import 'dart:math';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/currency_cheat_sheet.dart';
import '../../../domain/repositories/currency_repository.dart';

class CurrencyCheatSheetController extends GetxController {
  final CurrencyRepository _repository;

  CurrencyCheatSheetController(this._repository);

  final RxString baseCurrency = 'USD'.obs;
  final RxString targetCurrency = 'PKR'.obs;
  final Rxn<CurrencyRate> currentRate = Rxn<CurrencyRate>();
  final RxDouble spreadPercent =
      0.0.obs; // Bank ATM margin spread (e.g. 0% - 5%)
  final RxBool isReciprocal = false.obs; // Inverts conversion direction
  final RxBool isLoading = false.obs;

  // Tip Calculator state
  final RxDouble billAmount = 2500.0.obs;
  final RxDouble selectedTipPercent = 15.0.obs;
  final RxString selectedCategory = 'Dining & Bistro'.obs;
  final RxInt splitCount = 1.obs;
  final RxBool roundUpToNote = false.obs;

  static const List<String> supportedCurrencies = [
    'USD',
    'PKR',
    'EUR',
    'JPY',
    'AED',
    'GBP',
    'CHF',
  ];

  static const List<MerchantTipPreset> tipPresets = [
    MerchantTipPreset(
      category: 'Dining & Bistro',
      title: 'Dining & Bistro',
      defaultTipPercentage: 15.0,
      etiquetteNotice: 'Sit-down restaurants: 10-15% is customary in international hubs. In Japan, tipping is declined.',
    ),
    MerchantTipPreset(
      category: 'Expedition Guide & Porter',
      title: 'Guide & Porter',
      defaultTipPercentage: 12.0,
      etiquetteNotice: 'High-altitude alpine treks: 10-15% of expedition fee or fixed daily stipend is standard.',
    ),
    MerchantTipPreset(
      category: 'Taxi & Mountain Transit',
      title: 'Transit & Driver',
      defaultTipPercentage: 10.0,
      etiquetteNotice: 'Round up fare to the nearest paper note or add 10% for rough terrain driving.',
    ),
    MerchantTipPreset(
      category: 'Hotel & Hospitality',
      title: 'Hotel & Porter',
      defaultTipPercentage: 8.0,
      etiquetteNotice: 'Bellhop: 1-2 USD equivalent per bag. Housekeeping: 2-5 USD per night.',
    ),
    MerchantTipPreset(
      category: 'Counter & Street Food',
      title: 'Street Food',
      defaultTipPercentage: 0.0,
      etiquetteNotice: 'Bazaars and street stalls: No gratuity expected. Exact change is appreciated.',
    ),
  ];

  static const List<double> standardDenominations = [
    1,
    5,
    10,
    20,
    50,
    100,
    250,
    500,
    1000,
    5000,
  ];

  @override
  void onInit() {
    super.onInit();
    loadRate();
  }

  Future<void> loadRate() async {
    isLoading.value = true;
    try {
      final rate = await _repository.getRate(
        baseCurrency.value,
        targetCurrency.value,
      );
      if (rate != null) {
        currentRate.value = rate;
        spreadPercent.value = rate.spreadPercent;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void switchCurrencies() {
    final temp = baseCurrency.value;
    baseCurrency.value = targetCurrency.value;
    targetCurrency.value = temp;
    loadRate();
  }

  void toggleReciprocal() {
    isReciprocal.value = !isReciprocal.value;
  }

  void setBaseCurrency(String currency) {
    if (currency == targetCurrency.value) {
      switchCurrencies();
      return;
    }
    baseCurrency.value = currency;
    loadRate();
  }

  void setTargetCurrency(String currency) {
    if (currency == baseCurrency.value) {
      switchCurrencies();
      return;
    }
    targetCurrency.value = currency;
    loadRate();
  }

  Future<void> setSpreadPercent(double spread) async {
    spreadPercent.value = spread;
    if (currentRate.value != null) {
      final updated = currentRate.value!.copyWith(spreadPercent: spread);
      currentRate.value = updated;
      await _repository.updateSpread(
        baseCurrency.value,
        targetCurrency.value,
        spread,
      );
    }
  }

  Future<void> updateCustomRate(double newRate) async {
    if (newRate <= 0) return;
    final updated = CurrencyRate(
      baseCurrency: baseCurrency.value,
      targetCurrency: targetCurrency.value,
      rate: newRate,
      spreadPercent: spreadPercent.value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    currentRate.value = updated;
    await _repository.saveRate(updated);

    AppFeedback.showSuccess(
      title: 'Exchange Rate Calibrated',
      message:
          '1 ${baseCurrency.value} = ${newRate.toStringAsFixed(2)} ${targetCurrency.value}',
    );
  }

  // Cheat-Sheet Denominations
  List<CheatSheetDenomination> get cheatSheetDenominations {
    final rate = currentRate.value;
    if (rate == null) return [];

    final activeBase = isReciprocal.value
        ? targetCurrency.value
        : baseCurrency.value;
    final activeTarget = isReciprocal.value
        ? baseCurrency.value
        : targetCurrency.value;
    final multiplier = isReciprocal.value
        ? (rate.effectiveRate > 0 ? 1 / rate.effectiveRate : 1.0)
        : rate.effectiveRate;

    final numberFormat = NumberFormat('#,##0.00');

    return standardDenominations.map((denom) {
      final converted = denom * multiplier;
      return CheatSheetDenomination(
        baseAmount: denom,
        convertedAmount: converted,
        formattedBase: '$denom $activeBase',
        formattedConverted: '${numberFormat.format(converted)} $activeTarget',
      );
    }).toList();
  }

  // Tip calculation methods
  void setBillAmount(double amount) {
    billAmount.value = max(0.0, amount);
  }

  void setTipPercent(double percent) {
    selectedTipPercent.value = max(0.0, percent);
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    final preset = tipPresets.firstWhere(
      (p) => p.category == cat,
      orElse: () => tipPresets.first,
    );
    selectedTipPercent.value = preset.defaultTipPercentage;
  }

  void setSplitCount(int count) {
    splitCount.value = count.clamp(1, 10);
  }

  void toggleRoundUp() {
    roundUpToNote.value = !roundUpToNote.value;
  }

  MerchantTipPreset get activePreset {
    return tipPresets.firstWhere(
      (p) => p.category == selectedCategory.value,
      orElse: () => tipPresets.first,
    );
  }

  TipCalculation get tipCalculation {
    final bill = billAmount.value;
    final tipPct = selectedTipPercent.value;
    final tip = bill * (tipPct / 100);
    final rawTotal = bill + tip;

    double roundedTotal = rawTotal;
    double roundUpDiff = 0.0;

    if (roundUpToNote.value && rawTotal > 0) {
      if (rawTotal >= 500) {
        // Round to nearest 100
        roundedTotal = (rawTotal / 100).ceil() * 100.0;
      } else if (rawTotal >= 50) {
        // Round to nearest 10
        roundedTotal = (rawTotal / 10).ceil() * 10.0;
      } else {
        // Round to nearest whole integer
        roundedTotal = rawTotal.ceilToDouble();
      }
      roundUpDiff = roundedTotal - rawTotal;
    }

    final effectiveTip = tip + roundUpDiff;
    final effectiveTotal = roundedTotal;
    final splits = splitCount.value;

    return TipCalculation(
      billAmount: bill,
      tipPercentage: tipPct,
      tipAmount: effectiveTip,
      totalWithTip: effectiveTotal,
      splitCount: splits,
      perPersonBill: bill / splits,
      perPersonTip: effectiveTip / splits,
      perPersonTotal: effectiveTotal / splits,
      roundedTotal: roundedTotal,
      roundUpDifference: roundUpDiff,
    );
  }
}

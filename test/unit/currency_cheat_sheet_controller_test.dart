import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/domain/entities/currency_cheat_sheet.dart';
import 'package:voyage_ai_app/domain/repositories/currency_repository.dart';
import 'package:voyage_ai_app/presentation/currency/controllers/currency_cheat_sheet_controller.dart';

class MockCurrencyRepository implements CurrencyRepository {
  final Map<String, CurrencyRate> rates = {
    'USD_PKR': const CurrencyRate(
      baseCurrency: 'USD',
      targetCurrency: 'PKR',
      rate: 278.50,
      spreadPercent: 0.0,
      updatedAt: 1000,
    ),
    'USD_EUR': const CurrencyRate(
      baseCurrency: 'USD',
      targetCurrency: 'EUR',
      rate: 0.92,
      spreadPercent: 0.0,
      updatedAt: 1000,
    ),
    'PKR_USD': const CurrencyRate(
      baseCurrency: 'PKR',
      targetCurrency: 'USD',
      rate: 0.00359,
      spreadPercent: 0.0,
      updatedAt: 1000,
    ),
  };

  @override
  Future<List<CurrencyRate>> getStoredRates() async {
    return rates.values.toList();
  }

  @override
  Future<CurrencyRate?> getRate(String base, String target) async {
    final key = '${base}_$target';
    if (rates.containsKey(key)) return rates[key];

    final rate = CurrencyRate(
      baseCurrency: base,
      targetCurrency: target,
      rate: 1.0,
      spreadPercent: 0.0,
      updatedAt: 2000,
    );
    rates[key] = rate;
    return rate;
  }

  @override
  Future<void> saveRate(CurrencyRate rate) async {
    final key = '${rate.baseCurrency}_${rate.targetCurrency}';
    rates[key] = rate;
  }

  @override
  Future<void> updateSpread(
    String base,
    String target,
    double spreadPercent,
  ) async {
    final key = '${base}_$target';
    if (rates.containsKey(key)) {
      rates[key] = rates[key]!.copyWith(spreadPercent: spreadPercent);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCurrencyRepository mockRepo;
  late CurrencyCheatSheetController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockCurrencyRepository();
    controller = CurrencyCheatSheetController(mockRepo);
  });

  tearDown(() {
    Get.reset();
  });

  group('CurrencyCheatSheetController Unit Tests', () {
    test('Initial load retrieves stored exchange rate benchmark', () async {
      await controller.loadRate();
      expect(controller.currentRate.value, isNotNull);
      expect(controller.baseCurrency.value, 'USD');
      expect(controller.targetCurrency.value, 'PKR');
      expect(controller.currentRate.value!.rate, 278.50);
      expect(controller.spreadPercent.value, 0.0);
    });

    test('Generates denomination cheat-sheet intervals correctly', () async {
      await controller.loadRate();
      final denoms = controller.cheatSheetDenominations;

      expect(
        denoms.length,
        CurrencyCheatSheetController.standardDenominations.length,
      );
      expect(denoms.first.baseAmount, 1.0);
      expect(denoms.first.convertedAmount, closeTo(278.50, 0.01));
      expect(denoms.first.formattedBase, '1.0 USD');
      expect(denoms.first.formattedConverted.contains('278.50 PKR'), true);

      // Check 100 USD denomination
      final hundred = denoms.firstWhere((d) => d.baseAmount == 100.0);
      expect(hundred.convertedAmount, closeTo(27850.0, 0.1));
    });

    test('Toggles reciprocal mode and inverts conversion multiplier', () async {
      await controller.loadRate();
      expect(controller.isReciprocal.value, false);

      controller.toggleReciprocal();
      expect(controller.isReciprocal.value, true);

      final denoms = controller.cheatSheetDenominations;
      expect(denoms.first.formattedBase, '1.0 PKR');
      // 1 PKR = 1 / 278.50 USD = 0.00359 USD -> formats to ~0.00 USD
      expect(denoms.first.convertedAmount, closeTo(1 / 278.50, 0.0001));
    });

    test('Applies bank ATM spread margin buffer accurately', () async {
      await controller.loadRate();

      // Apply 2.0% bank conversion spread
      await controller.setSpreadPercent(2.0);
      expect(controller.spreadPercent.value, 2.0);

      // Effective rate = 278.50 * 1.02 = 284.07
      expect(
        controller.currentRate.value!.effectiveRate,
        closeTo(284.07, 0.01),
      );

      final denoms = controller.cheatSheetDenominations;
      final hundred = denoms.firstWhere((d) => d.baseAmount == 100.0);
      expect(hundred.convertedAmount, closeTo(28407.0, 0.1));
    });

    test('Calibrates custom manual exchange rate', () async {
      await controller.loadRate();

      await controller.updateCustomRate(280.0);
      expect(controller.currentRate.value!.rate, 280.0);

      final denoms = controller.cheatSheetDenominations;
      expect(denoms.first.convertedAmount, 280.0);
    });

    test('Computes multi-merchant tip and split bill breakdown', () {
      controller.setBillAmount(2000.0);
      controller.setTipPercent(15.0);
      controller.setSplitCount(2);

      final calc = controller.tipCalculation;
      expect(calc.billAmount, 2000.0);
      expect(calc.tipPercentage, 15.0);
      expect(calc.tipAmount, 300.0); // 15% of 2000 = 300
      expect(calc.totalWithTip, 2300.0);
      expect(calc.splitCount, 2);
      expect(calc.perPersonBill, 1000.0);
      expect(calc.perPersonTip, 150.0);
      expect(calc.perPersonTotal, 1150.0);
    });

    test('Rounds up to nearest note buffer when enabled', () {
      controller.setBillAmount(2340.0);
      controller.setTipPercent(10.0); // Tip = 234, Total = 2574
      controller.toggleRoundUp();

      final calc = controller.tipCalculation;
      // 2574 rounded to nearest 100 = 2600
      expect(calc.roundedTotal, 2600.0);
      expect(calc.roundUpDifference, 26.0);
      expect(calc.tipAmount, 260.0); // 234 + 26 = 260
    });

    test('Switches merchant category preset and updates etiquette advice', () {
      controller.selectCategory('Expedition Guide & Porter');
      expect(controller.selectedCategory.value, 'Expedition Guide & Porter');
      expect(controller.selectedTipPercent.value, 12.0);
      expect(
        controller.activePreset.etiquetteNotice.contains('High-altitude'),
        true,
      );

      controller.selectCategory('Counter & Street Food');
      expect(controller.selectedTipPercent.value, 0.0);
      expect(
        controller.activePreset.etiquetteNotice.contains('No gratuity'),
        true,
      );
    });
  });
}

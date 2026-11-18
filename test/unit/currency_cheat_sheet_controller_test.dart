import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/domain/entities/merchant_tip.dart';
import 'package:voyage_ai_app/domain/repositories/currency_repository.dart';
import 'package:voyage_ai_app/presentation/currency/controllers/currency_cheat_sheet_controller.dart';

class MockCurrencyRepository implements CurrencyRepository {
  Map<String, double> rates = {
    'USD': 1.0,
    'PKR': 278.50,
    'EUR': 0.92,
    'JPY': 154.20,
    'AED': 3.67,
    'GBP': 0.79,
    'CHF': 0.90,
  };

  List<Map<String, dynamic>> saved = [];

  @override
  Future<Map<String, double>> getExchangeRates() async => Map.from(rates);

  @override
  Future<void> updateCustomRate(String currencyCode, double rateToUsd) async {
    rates[currencyCode] = rateToUsd;
  }

  @override
  Future<void> resetRates() async {
    rates = {
      'USD': 1.0,
      'PKR': 278.50,
      'EUR': 0.92,
      'JPY': 154.20,
      'AED': 3.67,
      'GBP': 0.79,
      'CHF': 0.90,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedConversions() async =>
      List.from(saved);

  @override
  Future<void> saveConversion(
    String base,
    String target,
    double baseAmount,
    double convertedAmount,
  ) async {
    saved.insert(0, {
      'id': saved.length + 1,
      'base_currency': base,
      'target_currency': target,
      'base_amount': baseAmount,
      'converted_amount': convertedAmount,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> deleteConversion(int id) async {
    saved.removeWhere((item) => item['id'] == id);
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
    test(
      'Initializes with default rates and calculates direct exchange rate',
      () async {
        await controller.loadRates();
        expect(controller.baseCurrency.value, 'USD');
        expect(controller.targetCurrency.value, 'PKR');
        expect(controller.directExchangeRate, 278.50);
        expect(controller.inverseExchangeRate, closeTo(1.0 / 278.50, 0.0001));
      },
    );

    test('Swaps currencies and updates cross exchange rates', () async {
      await controller.loadRates();
      controller.swapCurrencies();

      expect(controller.baseCurrency.value, 'PKR');
      expect(controller.targetCurrency.value, 'USD');
      expect(controller.directExchangeRate, closeTo(1.0 / 278.50, 0.0001));
    });

    test(
      'Generates cash cheat-sheet matrix with standard denominations',
      () async {
        await controller.loadRates();
        final rows = controller.cheatSheetRows;

        expect(
          rows.length,
          CurrencyCheatSheetController.standardDenominations.length,
        );
        expect(rows.first.baseAmount, 1.0);
        expect(rows.first.convertedAmount, 278.50);
        expect(rows[1].baseAmount, 5.0);
        expect(rows[1].convertedAmount, 1392.50);
      },
    );

    test('Calculates tip and split amounts accurately for dining', () async {
      await controller.loadRates();
      controller.setBillAmount(1000.0);
      controller.setTipPercentage(10.0);
      controller.setMerchantType(MerchantType.dining);
      controller.setRoundingMode(RoundingMode.exact);

      final calc = controller.tipCalculation;
      expect(calc.billAmount, 1000.0);
      expect(calc.tipAmount, 100.0);
      expect(calc.totalAmount, 1100.0);
      expect(calc.perPersonTotal, 1100.0);

      // Split 4 ways
      controller.setSplitCount(4);
      final splitCalc = controller.tipCalculation;
      expect(splitCalc.splitCount, 4);
      expect(splitCalc.perPersonTotal, 275.0);
      expect(splitCalc.perPersonTip, 25.0);
    });

    test(
      'Applies roundUpTotal and roundUpPerPerson rounding modes correctly',
      () async {
        await controller.loadRates();
        controller.setBillAmount(1003.33);
        controller.setTipPercentage(10.0); // Tip = 100.333, Total = 1103.663
        controller.setSplitCount(3);

        controller.setRoundingMode(RoundingMode.roundUpTotal);
        final roundTotalCalc = controller.tipCalculation;
        expect(roundTotalCalc.totalAmount, 1104.0);

        controller.setRoundingMode(RoundingMode.roundUpPerPerson);
        final roundPersonCalc = controller.tipCalculation;
        // 1103.663 / 3 = 367.887 -> ceil = 368.0 -> total = 1104.0
        expect(roundPersonCalc.perPersonTotal, 368.0);
        expect(roundPersonCalc.totalAmount, 1104.0);
      },
    );

    test(
      'Updates custom exchange rate and updates cheat-sheet calculations',
      () async {
        await controller.loadRates();
        // Calibrate custom street cash rate for PKR to 282.0
        await controller.updateCustomRate(282.0);

        expect(controller.directExchangeRate, 282.0);
        final rows = controller.cheatSheetRows;
        expect(rows.first.convertedAmount, 282.0);

        // Reset rates back to reference
        await controller.resetRates();
        expect(controller.directExchangeRate, 278.50);
      },
    );

    test('Provides region-specific tipping etiquette guidance', () {
      controller.setTargetCurrency('JPY');
      expect(controller.tippingEtiquette.isTippingCustomary, false);
      expect(controller.tippingEtiquette.recommendedDiningPct, 0.0);

      controller.setTargetCurrency('PKR');
      expect(controller.tippingEtiquette.isTippingCustomary, true);
      expect(controller.tippingEtiquette.recommendedDiningPct, 10.0);

      controller.setTargetCurrency('USD');
      expect(controller.tippingEtiquette.isTippingCustomary, true);
      expect(controller.tippingEtiquette.recommendedDiningPct, 18.0);
    });

    test('Saves and deletes conversion snapshots in ledger history', () async {
      await controller.loadRates();
      controller.setBillAmount(2500.0);

      await controller.saveCurrentConversion();
      expect(controller.savedConversions.length, 1);

      final id = controller.savedConversions.first['id'] as int;
      await controller.deleteSavedConversion(id);
      expect(controller.savedConversions.isEmpty, true);
    });
  });
}

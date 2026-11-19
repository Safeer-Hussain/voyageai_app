import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyage_ai_app/core/theme/app_theme.dart';
import 'package:voyage_ai_app/core/theme/theme_controller.dart';
import 'package:voyage_ai_app/di/app_bindings.dart';
import 'package:voyage_ai_app/di/service_locator.dart';
import 'package:voyage_ai_app/domain/repositories/concierge_repository.dart';
import 'package:voyage_ai_app/domain/repositories/currency_repository.dart';
import 'package:voyage_ai_app/domain/repositories/document_repository.dart';
import 'package:voyage_ai_app/domain/repositories/expense_repository.dart';
import 'package:voyage_ai_app/domain/repositories/flight_claim_repository.dart';
import 'package:voyage_ai_app/domain/repositories/itinerary_repository.dart';
import 'package:voyage_ai_app/domain/repositories/jetlag_repository.dart';
import 'package:voyage_ai_app/domain/repositories/packing_repository.dart';
import 'package:voyage_ai_app/domain/repositories/telemetry_repository.dart';
import 'package:voyage_ai_app/presentation/currency/views/currency_cheat_sheet_view.dart';
import 'package:voyage_ai_app/presentation/currency/views/widgets/merchant_tip_calculator.dart';
import 'package:voyage_ai_app/presentation/currency/views/widgets/quick_reference_table.dart';

import '../unit/ai_concierge_controller_test.dart';
import '../unit/currency_cheat_sheet_controller_test.dart';
import '../unit/document_vault_controller_test.dart';
import '../unit/expense_ledger_controller_test.dart';
import '../unit/flight_claim_controller_test.dart';
import '../unit/itinerary_controller_test.dart';
import '../unit/jetlag_controller_test.dart';
import '../unit/packing_checklist_controller_test.dart';
import 'shell_hero_tags_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    if (sl.isRegistered<SharedPreferences>()) {
      sl.unregister<SharedPreferences>();
    }
    sl.registerSingleton<SharedPreferences>(prefs);

    if (sl.isRegistered<ThemeController>()) {
      sl.unregister<ThemeController>();
    }
    sl.registerSingleton<ThemeController>(ThemeController(prefs));

    if (sl.isRegistered<ItineraryRepository>()) {
      sl.unregister<ItineraryRepository>();
    }
    sl.registerSingleton<ItineraryRepository>(MockItineraryRepository());

    if (sl.isRegistered<DocumentRepository>()) {
      sl.unregister<DocumentRepository>();
    }
    sl.registerSingleton<DocumentRepository>(MockDocumentRepository());

    if (sl.isRegistered<ExpenseRepository>()) {
      sl.unregister<ExpenseRepository>();
    }
    sl.registerSingleton<ExpenseRepository>(MockExpenseRepository());

    if (sl.isRegistered<ConciergeRepository>()) {
      sl.unregister<ConciergeRepository>();
    }
    sl.registerSingleton<ConciergeRepository>(MockConciergeRepository());

    if (sl.isRegistered<TelemetryRepository>()) {
      sl.unregister<TelemetryRepository>();
    }
    sl.registerSingleton<TelemetryRepository>(MockTelemetryRepository());

    if (sl.isRegistered<PackingRepository>()) {
      sl.unregister<PackingRepository>();
    }
    sl.registerSingleton<PackingRepository>(MockPackingRepository());

    if (sl.isRegistered<JetlagRepository>()) {
      sl.unregister<JetlagRepository>();
    }
    sl.registerSingleton<JetlagRepository>(MockJetlagRepository());

    if (sl.isRegistered<CurrencyRepository>()) {
      sl.unregister<CurrencyRepository>();
    }
    sl.registerSingleton<CurrencyRepository>(MockCurrencyRepository());

    if (sl.isRegistered<FlightClaimRepository>()) {
      sl.unregister<FlightClaimRepository>();
    }
    sl.registerSingleton<FlightClaimRepository>(MockFlightClaimRepository());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'CurrencyCheatSheetView renders unique FAB heroTag, matrix, and tip cockpit',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.darkTheme,
          initialBinding: AppBindings(),
          home: const CurrencyCheatSheetView(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify unique FAB heroTag
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.heroTag, 'fab_currency_rate_override');

      // Verify cockpit widgets presence
      expect(find.byType(QuickReferenceTable), findsOneWidget);
      expect(find.byType(MerchantTipCalculator), findsOneWidget);

      // Verify text presence
      expect(find.text('CASH CHEAT-SHEET MATRIX'), findsOneWidget);
      expect(find.text('MULTI-MERCHANT TIP & SPLIT COCKPIT'), findsOneWidget);

      // Verify zero exceptions
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Zero RenderFlex overflow on 800x360 landscape viewport for CurrencyCheatSheetView',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.darkTheme,
          initialBinding: AppBindings(),
          home: const CurrencyCheatSheetView(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify two-pane layout rendered in landscape
      expect(find.byType(MerchantTipCalculator), findsOneWidget);
      expect(find.byType(QuickReferenceTable), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);
    },
  );
}

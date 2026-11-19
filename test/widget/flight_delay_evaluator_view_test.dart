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
import 'package:voyage_ai_app/presentation/flight_evaluator/views/flight_delay_evaluator_view.dart';

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
    'FlightDelayEvaluatorView renders unique FAB heroTag, inputs, and cockpit',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          initialBinding: AppBindings(),
          theme: AppTheme.darkTheme,
          home: const FlightDelayEvaluatorView(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify unique FAB heroTag
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.heroTag, equals('fab_flight_claim_evaluate'));

      // Verify parameters title
      expect(find.text('FLIGHT DISRUPTION PARAMETERS'), findsOneWidget);

      // Verify compensation banner
      expect(find.text('COMPENSATION APPROVED'), findsOneWidget);

      // Verify quick scenario chips
      expect(find.text('Short-Haul (BA LHR-FRA)'), findsOneWidget);
      expect(find.text('Long-Haul (AF CDG-JFK)'), findsOneWidget);

      // Tap Long-Haul Scenario chip
      await tester.tap(find.text('Long-Haul (AF CDG-JFK)'));
      await tester.pumpAndSettle();

      // Verify €600 compensation appears
      expect(find.text('€600'), findsOneWidget);
    },
  );

  testWidgets('Zero RenderFlex overflow errors on 800x360 landscape viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: AppBindings(),
        theme: AppTheme.darkTheme,
        home: const FlightDelayEvaluatorView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both panes rendered
    expect(find.text('FLIGHT DISRUPTION PARAMETERS'), findsOneWidget);
    expect(find.text('COMPENSATION APPROVED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

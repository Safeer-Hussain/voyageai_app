import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyage_ai_app/core/theme/app_theme.dart';
import 'package:voyage_ai_app/core/theme/theme_controller.dart';
import 'package:voyage_ai_app/di/app_bindings.dart';
import 'package:voyage_ai_app/di/service_locator.dart';
import 'package:voyage_ai_app/domain/entities/telemetry_packet.dart';
import 'package:voyage_ai_app/domain/repositories/concierge_repository.dart';
import 'package:voyage_ai_app/domain/repositories/currency_repository.dart';
import 'package:voyage_ai_app/domain/repositories/document_repository.dart';
import 'package:voyage_ai_app/domain/repositories/expense_repository.dart';
import 'package:voyage_ai_app/domain/repositories/itinerary_repository.dart';
import 'package:voyage_ai_app/domain/repositories/jetlag_repository.dart';
import 'package:voyage_ai_app/domain/repositories/packing_repository.dart';
import 'package:voyage_ai_app/domain/repositories/telemetry_repository.dart';
import 'package:voyage_ai_app/presentation/shell/views/adaptive_scaffold.dart';

import '../unit/ai_concierge_controller_test.dart';
import '../unit/currency_cheat_sheet_controller_test.dart';
import '../unit/document_vault_controller_test.dart';
import '../unit/expense_ledger_controller_test.dart';
import '../unit/itinerary_controller_test.dart';
import '../unit/jetlag_controller_test.dart';
import '../unit/packing_checklist_controller_test.dart';

class MockTelemetryRepository implements TelemetryRepository {
  @override
  Stream<TelemetryPacket> get telemetryStream => const Stream.empty();

  @override
  Future<Map<String, dynamic>> calibrateAltimeter({
    double? referenceAltitude,
  }) async => {'status': 'calibrated', 'offset': 0.0};

  @override
  Future<Map<String, dynamic>> triggerOfflineSosBeacon({
    required double latitude,
    required double longitude,
  }) async => {'status': 'active'};

  @override
  Future<Map<String, dynamic>> fetchLocalWeatherAdvisory({
    String? location,
  }) async => {
    'condition': 'Clear Alpine',
    'temperatureCelsius': 12.0,
    'location': 'Alpine Zone',
    'advisoryLevel': 'Normal',
    'windSpeedKph': 15,
    'visibilityKm': 15,
  };
}

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
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'Zero duplicate Hero tag exceptions across multi-tab shell transitions',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.darkTheme,
          initialBinding: AppBindings(),
          home: const AdaptiveScaffold(),
        ),
      );
      await tester.pumpAndSettle();

      final heroTags = <Object>{};

      // Tab 0: Itinerary
      final fabItinerary = find.byType(FloatingActionButton);
      expect(fabItinerary, findsOneWidget);
      final tag0 =
          (tester.widget(fabItinerary) as FloatingActionButton).heroTag;
      expect(tag0, isNotNull);
      expect(heroTags.contains(tag0), false);
      heroTags.add(tag0!);

      // Tab 1: Route Map
      await tester.tap(find.text('Route Map'));
      await tester.pumpAndSettle();
      final fabMap = find.byType(FloatingActionButton);
      if (fabMap.evaluate().isNotEmpty) {
        final tag1 =
            (tester.widget(fabMap.first) as FloatingActionButton).heroTag;
        expect(heroTags.contains(tag1), false);
        if (tag1 != null) heroTags.add(tag1);
      }

      // Tab 2: Pass Vault
      await tester.tap(find.text('Pass Vault'));
      await tester.pumpAndSettle();
      final fabVault = find.byType(FloatingActionButton);
      expect(fabVault, findsOneWidget);
      final tag2 = (tester.widget(fabVault) as FloatingActionButton).heroTag;
      expect(tag2, isNotNull);
      expect(heroTags.contains(tag2), false);
      heroTags.add(tag2!);

      // Tab 3: Ledger
      await tester.tap(find.text('Ledger'));
      await tester.pumpAndSettle();
      final fabLedger = find.byType(FloatingActionButton);
      expect(fabLedger, findsOneWidget);
      final tag3 = (tester.widget(fabLedger) as FloatingActionButton).heroTag;
      expect(tag3, isNotNull);
      expect(heroTags.contains(tag3), false);
      heroTags.add(tag3!);

      // Tab 4: AI & HUD
      await tester.tap(find.text('AI & HUD'));
      await tester.pumpAndSettle();
      final fabConcierge = find.byType(FloatingActionButton);
      expect(fabConcierge, findsOneWidget);
      final tag4 =
          (tester.widget(fabConcierge) as FloatingActionButton).heroTag;
      expect(tag4, isNotNull);
      expect(heroTags.contains(tag4), false);
      heroTags.add(tag4!);

      expect(tester.takeException(), isNull);
    },
  );
}

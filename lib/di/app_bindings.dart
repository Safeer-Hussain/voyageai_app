import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/repositories/concierge_repository.dart';
import '../domain/repositories/document_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/itinerary_repository.dart';
import '../domain/repositories/jetlag_repository.dart';
import '../domain/repositories/packing_repository.dart';
import '../domain/repositories/telemetry_repository.dart';
import '../presentation/ai_concierge/controllers/ai_concierge_controller.dart';
import '../presentation/document_vault/controllers/document_vault_controller.dart';
import '../presentation/expense_ledger/controllers/expense_ledger_controller.dart';
import '../presentation/itinerary/controllers/itinerary_controller.dart';
import '../presentation/jetlag/controllers/jetlag_controller.dart';
import '../presentation/packing/controllers/packing_checklist_controller.dart';
import '../presentation/route_map/controllers/route_map_controller.dart';
import '../presentation/shell/controllers/navigation_controller.dart';
import '../presentation/telemetry_hud/controllers/telemetry_hud_controller.dart';
import 'service_locator.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(NavigationController());

    Get.put<ItineraryController>(
      ItineraryController(sl<ItineraryRepository>(), sl<SharedPreferences>()),
    );

    Get.put<RouteMapController>(RouteMapController(sl<ItineraryRepository>()));

    Get.put<DocumentVaultController>(
      DocumentVaultController(sl<DocumentRepository>()),
    );

    Get.put<ExpenseLedgerController>(
      ExpenseLedgerController(sl<ExpenseRepository>(), sl<SharedPreferences>()),
    );

    Get.put<PackingChecklistController>(
      PackingChecklistController(sl<PackingRepository>()),
    );

    Get.put<JetlagController>(JetlagController(sl<JetlagRepository>()));

    Get.put<AiConciergeController>(
      AiConciergeController(sl<ConciergeRepository>()),
    );

    Get.put<TelemetryHudController>(
      TelemetryHudController(sl<TelemetryRepository>()),
    );
  }
}

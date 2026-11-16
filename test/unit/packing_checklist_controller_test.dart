import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/domain/entities/packing_item.dart';
import 'package:voyage_ai_app/domain/repositories/packing_repository.dart';
import 'package:voyage_ai_app/presentation/packing/controllers/packing_checklist_controller.dart';

class MockPackingRepository implements PackingRepository {
  List<PackingItem> items = [
    const PackingItem(
      id: 'pack_1',
      tripId: 'trip_hunza_7d',
      title: 'Alpine Climbing Harness',
      category: 'Technical Gear',
      weightKg: 1.2,
      isPacked: false,
      isEssential: true,
    ),
    const PackingItem(
      id: 'pack_2',
      tripId: 'trip_hunza_7d',
      title: 'Thermal Merino Base Layer',
      category: 'Thermal Apparel',
      weightKg: 0.8,
      isPacked: true,
      isEssential: true,
    ),
    const PackingItem(
      id: 'pack_3',
      tripId: 'trip_hunza_7d',
      title: 'Expedition First Aid & Trauma Kit',
      category: 'Medical & Health',
      weightKg: 1.5,
      isPacked: false,
      isEssential: true,
    ),
    const PackingItem(
      id: 'pack_4',
      tripId: 'trip_hunza_7d',
      title: 'Satellite Messenger & Solar Battery',
      category: 'Field Electronics',
      weightKg: 0.9,
      isPacked: false,
      isEssential: false,
    ),
  ];

  @override
  Future<List<PackingItem>> getPackingItemsForTrip(String tripId) async {
    return items.where((i) => i.tripId == tripId).toList();
  }

  @override
  Future<void> addPackingItem(PackingItem item) async {
    items.insert(0, item);
  }

  @override
  Future<void> toggleItemPacked(String itemId, bool isPacked) async {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(isPacked: isPacked);
    }
  }

  @override
  Future<void> deletePackingItem(String itemId) async {
    items.removeWhere((i) => i.id == itemId);
  }

  @override
  Future<void> autoPackEssentials(String tripId) async {
    for (int i = 0; i < items.length; i++) {
      if (items[i].tripId == tripId && items[i].isEssential) {
        items[i] = items[i].copyWith(isPacked: true);
      }
    }
  }

  @override
  Future<void> resetChecklist(String tripId) async {
    for (int i = 0; i < items.length; i++) {
      if (items[i].tripId == tripId) {
        items[i] = items[i].copyWith(isPacked: false);
      }
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPackingRepository mockRepo;
  late PackingChecklistController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockPackingRepository();
    controller = PackingChecklistController(mockRepo);
  });

  tearDown(() {
    Get.reset();
  });

  group('PackingChecklistController Unit Tests', () {
    test('Initial load populates items for active expedition', () async {
      await controller.loadItems('trip_hunza_7d');
      expect(controller.items.length, 4);
      expect(controller.activeTripId.value, 'trip_hunza_7d');
      expect(controller.isLoading.value, false);
    });

    test(
      'Calculates packed weight and remaining allowance correctly',
      () async {
        await controller.loadItems('trip_hunza_7d');
        // Only pack_2 is packed initially (0.8 kg)
        expect(controller.totalPackedWeightKg, 0.8);
        expect(controller.totalChecklistWeightKg, closeTo(4.4, 0.01));
        expect(controller.selectedAllowanceKg.value, 23.0);
        expect(controller.remainingAllowanceKg, closeTo(22.2, 0.01));
        expect(controller.weightBurnRatio, closeTo(0.8 / 23.0, 0.01));
        expect(controller.isOverweight, false);
      },
    );

    test('Toggles item packed state and recalculates weight metrics', () async {
      await controller.loadItems('trip_hunza_7d');
      expect(
        controller.items.firstWhere((i) => i.id == 'pack_1').isPacked,
        false,
      );

      await controller.toggleItemPacked('pack_1');
      expect(
        controller.items.firstWhere((i) => i.id == 'pack_1').isPacked,
        true,
      );
      // pack_1 (1.2 kg) + pack_2 (0.8 kg) = 2.0 kg
      expect(controller.totalPackedWeightKg, closeTo(2.0, 0.01));
      expect(controller.remainingAllowanceKg, closeTo(21.0, 0.01));
    });

    test('Auto-pack essentials marks all critical gear as packed', () async {
      await controller.loadItems('trip_hunza_7d');
      await controller.autoPackEssentials();

      final packedItems = controller.items.where((i) => i.isPacked).toList();
      expect(packedItems.length, 3);
      // Non-essential item (pack_4) remains unpacked
      final nonEssential = controller.items.firstWhere((i) => i.id == 'pack_4');
      expect(nonEssential.isPacked, false);
    });

    test('Reset checklist resets all items to unpacked', () async {
      await controller.loadItems('trip_hunza_7d');
      await controller.resetChecklist();

      expect(controller.items.every((i) => !i.isPacked), true);
      expect(controller.totalPackedWeightKg, 0.0);
      expect(controller.remainingAllowanceKg, 23.0);
    });

    test('Toggles weight unit between KG and LBS with conversion accuracy', () {
      expect(controller.weightUnit.value, 'KG');
      expect(controller.formatWeight(10.0), '10.0 KG');

      controller.toggleWeightUnit();
      expect(controller.weightUnit.value, 'LBS');
      expect(controller.formatWeight(10.0), '22.0 LBS');

      controller.toggleWeightUnit();
      expect(controller.weightUnit.value, 'KG');
    });

    test('Filters items by category and packed status', () async {
      await controller.loadItems('trip_hunza_7d');

      controller.selectCategory('Thermal Apparel');
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.title, 'Thermal Merino Base Layer');

      controller.selectCategory('Packed');
      expect(controller.filteredItems.length, 1);
      expect(controller.filteredItems.first.id, 'pack_2');

      controller.selectCategory('Remaining');
      expect(controller.filteredItems.length, 3);

      controller.selectCategory('All');
      expect(controller.filteredItems.length, 4);
    });

    test('Adds and deletes packing items cleanly', () async {
      await controller.loadItems('trip_hunza_7d');

      await controller.addItem(
        title: 'Emergency Bivy Sack',
        category: 'Technical Gear',
        weightKg: 0.35,
        isEssential: true,
      );

      expect(controller.items.length, 5);
      expect(controller.items.first.title, 'Emergency Bivy Sack');

      final addedId = controller.items.first.id;
      await controller.deleteItem(addedId);
      expect(controller.items.length, 4);
      expect(controller.items.any((i) => i.id == addedId), false);
    });
  });
}

import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/packing_item.dart';
import '../../../domain/repositories/packing_repository.dart';

class PackingChecklistController extends GetxController {
  final PackingRepository _repository;

  PackingChecklistController(this._repository);

  final RxList<PackingItem> items = <PackingItem>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxDouble selectedAllowanceKg =
      23.0.obs; // Standard checked baggage limit
  final RxString weightUnit = 'KG'.obs;
  final RxBool isLoading = false.obs;
  final RxString activeTripId = 'trip_hunza_7d'.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems(activeTripId.value);
  }

  static const List<String> categories = [
    'All',
    'Remaining',
    'Packed',
    'Technical Gear',
    'Thermal Apparel',
    'Medical & Health',
    'Field Electronics',
    'Travel Documents',
  ];

  static const List<double> standardAllowances = [7.0, 23.0, 32.0];

  Future<void> loadItems(String tripId) async {
    activeTripId.value = tripId;
    isLoading.value = true;
    try {
      final loaded = await _repository.getPackingItemsForTrip(tripId);
      items.assignAll(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void setAllowance(double kg) {
    selectedAllowanceKg.value = kg;
  }

  void toggleWeightUnit() {
    weightUnit.value = weightUnit.value == 'KG' ? 'LBS' : 'KG';
  }

  double convertWeight(double kg) {
    if (weightUnit.value == 'LBS') {
      return kg * 2.20462;
    }
    return kg;
  }

  String formatWeight(double kg) {
    final value = convertWeight(kg);
    final unit = weightUnit.value;
    return '${value.toStringAsFixed(1)} $unit';
  }

  double get totalPackedWeightKg {
    return items
        .where((i) => i.isPacked)
        .fold<double>(0.0, (sum, i) => sum + i.weightKg);
  }

  double get totalChecklistWeightKg {
    return items.fold<double>(0.0, (sum, i) => sum + i.weightKg);
  }

  double get remainingAllowanceKg {
    return selectedAllowanceKg.value - totalPackedWeightKg;
  }

  double get weightBurnRatio {
    if (selectedAllowanceKg.value <= 0) return 0.0;
    return (totalPackedWeightKg / selectedAllowanceKg.value).clamp(0.0, 1.0);
  }

  bool get isOverweight {
    return totalPackedWeightKg > selectedAllowanceKg.value;
  }

  double get packingProgressPercentage {
    if (items.isEmpty) return 0.0;
    final packedCount = items.where((i) => i.isPacked).length;
    return packedCount / items.length;
  }

  List<PackingItem> get filteredItems {
    if (selectedCategory.value == 'All') return items;
    if (selectedCategory.value == 'Packed') {
      return items.where((i) => i.isPacked).toList();
    }
    if (selectedCategory.value == 'Remaining') {
      return items.where((i) => !i.isPacked).toList();
    }
    return items
        .where(
          (i) =>
              i.category.toLowerCase() == selectedCategory.value.toLowerCase(),
        )
        .toList();
  }

  Future<void> toggleItemPacked(String itemId) async {
    final index = items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final current = items[index];
      final updated = current.copyWith(isPacked: !current.isPacked);
      items[index] = updated;
      items.refresh();

      await _repository.toggleItemPacked(itemId, updated.isPacked);
    }
  }

  Future<bool> addItem({
    required String title,
    required String category,
    required double weightKg,
    required bool isEssential,
  }) async {
    final newItem = PackingItem(
      id: 'pack_${DateTime.now().millisecondsSinceEpoch}',
      tripId: activeTripId.value,
      title: title,
      category: category,
      weightKg: weightKg,
      isPacked: false,
      isEssential: isEssential,
    );

    items.insert(0, newItem);
    items.refresh();
    await _repository.addPackingItem(newItem);

    AppFeedback.showSuccess(
      title: 'Item Added',
      message: '$title (${formatWeight(weightKg)}) added to packing checklist.',
    );
    return true;
  }

  Future<void> deleteItem(String itemId) async {
    items.removeWhere((i) => i.id == itemId);
    items.refresh();
    await _repository.deletePackingItem(itemId);

    AppFeedback.showInfo(
      title: 'Item Removed',
      message: 'Item deleted from checklist.',
    );
  }

  Future<void> autoPackEssentials() async {
    for (int i = 0; i < items.length; i++) {
      if (items[i].isEssential) {
        items[i] = items[i].copyWith(isPacked: true);
      }
    }
    items.refresh();
    await _repository.autoPackEssentials(activeTripId.value);

    AppFeedback.showSuccess(
      title: 'Essentials Packed',
      message: 'All mission-critical expedition gear marked as packed.',
    );
  }

  Future<void> resetChecklist() async {
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(isPacked: false);
    }
    items.refresh();
    await _repository.resetChecklist(activeTripId.value);

    AppFeedback.showInfo(
      title: 'Checklist Reset',
      message: 'All packing items reset to unpacked.',
    );
  }
}

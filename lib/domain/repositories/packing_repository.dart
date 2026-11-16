import '../entities/packing_item.dart';

abstract class PackingRepository {
  Future<List<PackingItem>> getPackingItemsForTrip(String tripId);
  Future<void> addPackingItem(PackingItem item);
  Future<void> toggleItemPacked(String itemId, bool isPacked);
  Future<void> deletePackingItem(String itemId);
  Future<void> autoPackEssentials(String tripId);
  Future<void> resetChecklist(String tripId);
}

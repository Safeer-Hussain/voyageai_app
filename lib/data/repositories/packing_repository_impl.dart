import '../../domain/entities/packing_item.dart';
import '../../domain/repositories/packing_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/packing_item_model.dart';

class PackingRepositoryImpl implements PackingRepository {
  final LocalStorageDatasource _datasource;

  PackingRepositoryImpl(this._datasource);

  @override
  Future<List<PackingItem>> getPackingItemsForTrip(String tripId) async {
    return await _datasource.getPackingItemsForTrip(tripId);
  }

  @override
  Future<void> addPackingItem(PackingItem item) async {
    await _datasource.insertPackingItem(PackingItemModel.fromEntity(item));
  }

  @override
  Future<void> toggleItemPacked(String itemId, bool isPacked) async {
    await _datasource.updatePackingItemStatus(itemId, isPacked);
  }

  @override
  Future<void> deletePackingItem(String itemId) async {
    await _datasource.deletePackingItem(itemId);
  }

  @override
  Future<void> autoPackEssentials(String tripId) async {
    await _datasource.autoPackEssentials(tripId);
  }

  @override
  Future<void> resetChecklist(String tripId) async {
    await _datasource.resetChecklist(tripId);
  }
}

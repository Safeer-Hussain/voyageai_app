import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import '../models/activity_model.dart';
import '../models/document_model.dart';
import '../models/expense_model.dart';
import '../models/packing_item_model.dart';
import '../models/trip_model.dart';
import '../models/waypoint_model.dart';

class LocalStorageDatasource {
  final AppDatabase _appDatabase;

  LocalStorageDatasource(this._appDatabase);

  Future<Database> get _db => _appDatabase.database;

  // Trips
  Future<List<TripModel>> getTrips() async {
    final db = await _db;
    final results = await db.query('trips', orderBy: 'created_at ASC');
    return results.map((m) => TripModel.fromMap(m)).toList();
  }

  Future<TripModel?> getTripById(String id) async {
    final db = await _db;
    final results = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return TripModel.fromMap(results.first);
  }

  Future<void> insertTrip(TripModel trip) async {
    final db = await _db;
    await db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Activities
  Future<List<ActivityModel>> getActivitiesForTrip(String tripId) async {
    final db = await _db;
    final results = await db.query(
      'activities',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'day_number ASC, time_slot ASC',
    );
    return results.map((m) => ActivityModel.fromMap(m)).toList();
  }

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await _db;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivityStatus(String activityId, bool isCompleted) async {
    final db = await _db;
    await db.update(
      'activities',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [activityId],
    );
  }

  Future<void> deleteActivity(String activityId) async {
    final db = await _db;
    await db.delete('activities', where: 'id = ?', whereArgs: [activityId]);
  }

  // Waypoints
  Future<List<WaypointModel>> getWaypointsForTrip(String tripId) async {
    final db = await _db;
    final results = await db.query(
      'waypoints',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'day_number ASC',
    );
    return results.map((m) => WaypointModel.fromMap(m)).toList();
  }

  Future<void> insertWaypoint(WaypointModel waypoint) async {
    final db = await _db;
    await db.insert(
      'waypoints',
      waypoint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Documents
  Future<List<DocumentModel>> getDocumentsForTrip(String tripId) async {
    final db = await _db;
    final results = await db.query(
      'documents',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
    return results.map((m) => DocumentModel.fromMap(m)).toList();
  }

  Future<void> insertDocument(DocumentModel doc) async {
    final db = await _db;
    await db.insert(
      'documents',
      doc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDocument(String documentId) async {
    final db = await _db;
    await db.delete('documents', where: 'id = ?', whereArgs: [documentId]);
  }

  // Expenses
  Future<List<ExpenseModel>> getExpensesForTrip(String tripId) async {
    final db = await _db;
    final results = await db.query(
      'expenses',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'timestamp DESC',
    );
    return results.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await _db;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [expenseId]);
  }

  // Packing Items
  Future<List<PackingItemModel>> getPackingItemsForTrip(String tripId) async {
    final db = await _db;
    final results = await db.query(
      'packing_items',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'is_essential DESC, title ASC',
    );
    return results.map((m) => PackingItemModel.fromMap(m)).toList();
  }

  Future<void> insertPackingItem(PackingItemModel item) async {
    final db = await _db;
    await db.insert(
      'packing_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePackingItemStatus(String itemId, bool isPacked) async {
    final db = await _db;
    await db.update(
      'packing_items',
      {'is_packed': isPacked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> deletePackingItem(String itemId) async {
    final db = await _db;
    await db.delete('packing_items', where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> autoPackEssentials(String tripId) async {
    final db = await _db;
    await db.update(
      'packing_items',
      {'is_packed': 1},
      where: 'trip_id = ? AND is_essential = 1',
      whereArgs: [tripId],
    );
  }

  Future<void> resetChecklist(String tripId) async {
    final db = await _db;
    await db.update(
      'packing_items',
      {'is_packed': 0},
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
  }
}

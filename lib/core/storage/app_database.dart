import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/mock_expeditions.dart';

class AppDatabase {
  static const String databaseName = 'voyage_ai.db';
  static const int databaseVersion = 1;

  Database? _db;

  AppDatabase({Database? db}) {
    _db = db;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        destination TEXT NOT NULL,
        duration_days INTEGER NOT NULL,
        pace TEXT NOT NULL,
        budget_tier TEXT NOT NULL,
        total_budget_usd REAL NOT NULL,
        image_asset TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        day_number INTEGER NOT NULL,
        time_slot TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        cost_usd REAL NOT NULL,
        is_completed INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE waypoints (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        day_number INTEGER NOT NULL,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        category TEXT NOT NULL,
        altitude_meters REAL NOT NULL,
        local_tips TEXT NOT NULL,
        transit_duration_mins INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        origin_iata TEXT NOT NULL,
        destination_iata TEXT NOT NULL,
        flight_or_booking_number TEXT NOT NULL,
        gate TEXT NOT NULL,
        seat TEXT NOT NULL,
        boarding_time TEXT NOT NULL,
        pnr_code TEXT NOT NULL,
        carrier_name TEXT NOT NULL,
        qr_payload TEXT NOT NULL,
        notes TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        original_amount REAL NOT NULL,
        currency_code TEXT NOT NULL,
        amount_usd REAL NOT NULL,
        split_count INTEGER NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS packing_items (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        weight_kg REAL NOT NULL,
        is_packed INTEGER NOT NULL,
        is_essential INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS jetlag_plans (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        origin_city TEXT NOT NULL,
        origin_tz_offset INTEGER NOT NULL,
        destination_city TEXT NOT NULL,
        destination_tz_offset INTEGER NOT NULL,
        departure_timestamp INTEGER NOT NULL,
        arrival_timestamp INTEGER NOT NULL,
        direction TEXT NOT NULL,
        total_hour_shift INTEGER NOT NULL,
        days_to_adapt INTEGER NOT NULL,
        shift_days_json TEXT NOT NULL
      )
    ''');
  }

  Future<void> seedInitialDataIfEmpty() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS packing_items (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        weight_kg REAL NOT NULL,
        is_packed INTEGER NOT NULL,
        is_essential INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS jetlag_plans (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        origin_city TEXT NOT NULL,
        origin_tz_offset INTEGER NOT NULL,
        destination_city TEXT NOT NULL,
        destination_tz_offset INTEGER NOT NULL,
        departure_timestamp INTEGER NOT NULL,
        arrival_timestamp INTEGER NOT NULL,
        direction TEXT NOT NULL,
        total_hour_shift INTEGER NOT NULL,
        days_to_adapt INTEGER NOT NULL,
        shift_days_json TEXT NOT NULL
      )
    ''');

    final tripsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM trips'),
    );

    if (tripsCount == null || tripsCount == 0) {
      final batch = db.batch();

      for (final trip in MockExpeditions.initialTrips) {
        batch.insert('trips', trip);
      }
      for (final activity in MockExpeditions.initialActivities) {
        batch.insert('activities', activity);
      }
      for (final waypoint in MockExpeditions.initialWaypoints) {
        batch.insert('waypoints', waypoint);
      }
      for (final doc in MockExpeditions.initialDocuments) {
        batch.insert('documents', doc);
      }
      for (final expense in MockExpeditions.initialExpenses) {
        batch.insert('expenses', expense);
      }
      for (final packing in MockExpeditions.initialPackingItems) {
        batch.insert('packing_items', packing);
      }
      for (final plan in MockExpeditions.initialJetlagPlans) {
        batch.insert('jetlag_plans', plan);
      }

      await batch.commit(noResult: true);
    } else {
      final packingCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM packing_items'),
      );
      if (packingCount == null || packingCount == 0) {
        final batch = db.batch();
        for (final packing in MockExpeditions.initialPackingItems) {
          batch.insert('packing_items', packing);
        }
        await batch.commit(noResult: true);
      }

      final jetlagCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM jetlag_plans'),
      );
      if (jetlagCount == null || jetlagCount == 0) {
        final batch = db.batch();
        for (final plan in MockExpeditions.initialJetlagPlans) {
          batch.insert('jetlag_plans', plan);
        }
        await batch.commit(noResult: true);
      }
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('activities');
    await db.delete('waypoints');
    await db.delete('documents');
    await db.delete('expenses');
    await db.delete('packing_items');
    await db.delete('jetlag_plans');
    await db.delete('trips');
  }
}

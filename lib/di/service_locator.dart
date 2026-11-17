import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/platform/telemetry_bridge.dart';
import '../core/storage/app_database.dart';
import '../core/theme/theme_controller.dart';
import '../data/datasources/local_storage_datasource.dart';
import '../data/repositories/concierge_repository_impl.dart';
import '../data/repositories/document_repository_impl.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../data/repositories/itinerary_repository_impl.dart';
import '../data/repositories/jetlag_repository_impl.dart';
import '../data/repositories/packing_repository_impl.dart';
import '../data/repositories/telemetry_repository_impl.dart';
import '../domain/repositories/concierge_repository.dart';
import '../domain/repositories/document_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/itinerary_repository.dart';
import '../domain/repositories/jetlag_repository.dart';
import '../domain/repositories/packing_repository.dart';
import '../domain/repositories/telemetry_repository.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator({
  SharedPreferences? testPrefs,
  AppDatabase? testDb,
}) async {
  // SharedPreferences
  final prefs = testPrefs ?? await SharedPreferences.getInstance();
  if (sl.isRegistered<SharedPreferences>()) {
    sl.unregister<SharedPreferences>();
  }
  sl.registerSingleton<SharedPreferences>(prefs);

  // AppDatabase
  final appDb = testDb ?? AppDatabase();
  if (sl.isRegistered<AppDatabase>()) {
    sl.unregister<AppDatabase>();
  }
  sl.registerSingleton<AppDatabase>(appDb);

  // Data Source
  if (sl.isRegistered<LocalStorageDatasource>()) {
    sl.unregister<LocalStorageDatasource>();
  }
  sl.registerLazySingleton<LocalStorageDatasource>(
    () => LocalStorageDatasource(sl<AppDatabase>()),
  );

  // Platform Telemetry Bridge
  if (sl.isRegistered<TelemetryBridge>()) {
    sl.unregister<TelemetryBridge>();
  }
  sl.registerLazySingleton<TelemetryBridge>(() => TelemetryBridge());

  // API Client
  if (sl.isRegistered<ApiClient>()) {
    sl.unregister<ApiClient>();
  }
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<SharedPreferences>()));

  // Repositories
  if (sl.isRegistered<ItineraryRepository>()) {
    sl.unregister<ItineraryRepository>();
  }
  sl.registerLazySingleton<ItineraryRepository>(
    () => ItineraryRepositoryImpl(sl<LocalStorageDatasource>()),
  );

  if (sl.isRegistered<DocumentRepository>()) {
    sl.unregister<DocumentRepository>();
  }
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(sl<LocalStorageDatasource>()),
  );

  if (sl.isRegistered<ExpenseRepository>()) {
    sl.unregister<ExpenseRepository>();
  }
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl<LocalStorageDatasource>()),
  );

  if (sl.isRegistered<ConciergeRepository>()) {
    sl.unregister<ConciergeRepository>();
  }
  sl.registerLazySingleton<ConciergeRepository>(
    () => ConciergeRepositoryImpl(sl<LocalStorageDatasource>()),
  );

  if (sl.isRegistered<TelemetryRepository>()) {
    sl.unregister<TelemetryRepository>();
  }
  sl.registerLazySingleton<TelemetryRepository>(
    () => TelemetryRepositoryImpl(sl<TelemetryBridge>()),
  );

  if (sl.isRegistered<PackingRepository>()) {
    sl.unregister<PackingRepository>();
  }
  sl.registerLazySingleton<PackingRepository>(
    () => PackingRepositoryImpl(sl<LocalStorageDatasource>()),
  );

  if (sl.isRegistered<JetlagRepository>()) {
    sl.unregister<JetlagRepository>();
  }
  sl.registerLazySingleton<JetlagRepository>(
    () => JetlagRepositoryImpl(sl<LocalStorageDatasource>()),
  );

  // Controllers
  if (sl.isRegistered<ThemeController>()) {
    sl.unregister<ThemeController>();
  }
  sl.registerSingleton<ThemeController>(
    ThemeController(sl<SharedPreferences>()),
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyage_ai_app/domain/entities/activity.dart';
import 'package:voyage_ai_app/domain/entities/trip.dart';
import 'package:voyage_ai_app/domain/entities/waypoint.dart';
import 'package:voyage_ai_app/domain/repositories/itinerary_repository.dart';
import 'package:voyage_ai_app/presentation/itinerary/controllers/itinerary_controller.dart';

class MockItineraryRepository implements ItineraryRepository {
  List<Trip> trips = [
    const Trip(
      id: 'trip_hunza_7d',
      title: '7-Day Northern Pakistan & Hunza Expedition',
      destination: 'Hunza Valley',
      durationDays: 7,
      pace: 'Packed',
      budgetTier: 'Expedition Tier',
      totalBudgetUsd: 2850.0,
      imageAsset: 'assets/images/karakoram_hunza.png',
      createdAt: 1000,
    ),
    const Trip(
      id: 'trip_tokyo_5d',
      title: '5-Day Tokyo & Kyoto Tech Tour',
      destination: 'Tokyo, Japan',
      durationDays: 5,
      pace: 'Balanced',
      budgetTier: 'Premium Executive',
      totalBudgetUsd: 3600.0,
      imageAsset: 'assets/images/tokyo_shibuya.png',
      createdAt: 2000,
    ),
  ];

  List<Activity> activities = [
    const Activity(
      id: 'act_1',
      tripId: 'trip_hunza_7d',
      dayNumber: 1,
      timeSlot: '08:00 - 10:00',
      title: 'Mountain Flight PK-451',
      description: 'Flight over Karakoram',
      category: 'Flight',
      costUsd: 140.0,
      isCompleted: false,
      latitude: 35.33,
      longitude: 75.53,
    ),
  ];

  @override
  Future<List<Trip>> getTrips() async => trips;

  @override
  Future<Trip?> getTripById(String id) async =>
      trips.where((t) => t.id == id).firstOrNull;

  @override
  Future<void> createTrip(Trip trip) async => trips.add(trip);

  @override
  Future<List<Activity>> getActivitiesForTrip(String tripId) async =>
      activities.where((a) => a.tripId == tripId).toList();

  @override
  Future<void> addActivity(Activity activity) async => activities.add(activity);

  @override
  Future<void> toggleActivityCompleted(
    String activityId,
    bool isCompleted,
  ) async {
    final idx = activities.indexWhere((a) => a.id == activityId);
    if (idx != -1) {
      activities[idx] = activities[idx].copyWith(isCompleted: isCompleted);
    }
  }

  @override
  Future<void> deleteActivity(String activityId) async =>
      activities.removeWhere((a) => a.id == activityId);

  @override
  Future<List<Waypoint>> getWaypointsForTrip(String tripId) async => [];

  @override
  Future<Trip> generateAiTrip({
    required String destination,
    required int durationDays,
    required String pace,
    required String budgetTier,
  }) async {
    final newTrip = Trip(
      id: 'trip_generated_1',
      title: '$durationDays-Day $destination Expedition',
      destination: destination,
      durationDays: durationDays,
      pace: pace,
      budgetTier: budgetTier,
      totalBudgetUsd: 1500.0,
      imageAsset: 'assets/images/karakoram_hunza.png',
      createdAt: 3000,
    );
    trips.add(newTrip);
    return newTrip;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockItineraryRepository mockRepo;
  late SharedPreferences prefs;
  late ItineraryController controller;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockRepo = MockItineraryRepository();
    controller = ItineraryController(mockRepo, prefs);
    await controller.loadInitialData();
  });

  group('ItineraryController Unit Tests', () {
    test('Initial data loads and selects the first available expedition', () {
      expect(controller.trips.length, 2);
      expect(controller.activeTrip.value?.id, 'trip_hunza_7d');
      expect(controller.activities.length, 1);
    });

    test(
      'switchTrip updates active trip, resets day to 1 and loads activities',
      () async {
        await controller.switchTrip('trip_tokyo_5d');
        expect(controller.activeTrip.value?.id, 'trip_tokyo_5d');
        expect(controller.selectedDay.value, 1);
      },
    );

    test('toggleActivityCompleted toggles completion state and updates progress bar', () async {
      expect(controller.tripCompletionPercentage, 0.0);
      await controller.toggleActivityCompleted('act_1');
      expect(controller.activities.first.isCompleted, true);
      expect(controller.tripCompletionPercentage, 1.0);
    });

    test(
      'generateAiTrip synthesizes new expedition and sets it as active',
      () async {
        await controller.generateAiTrip(
          destination: 'Swiss Alps Panorama',
          durationDays: 4,
          pace: 'Relaxed',
          budgetTier: 'Luxury Alpine',
        );
        expect(controller.trips.length, 3);
        expect(controller.activeTrip.value?.destination, 'Swiss Alps Panorama');
        expect(controller.activeTrip.value?.durationDays, 4);
      },
    );
  });
}

import '../../domain/entities/activity.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/activity_model.dart';
import '../models/trip_model.dart';
import '../models/waypoint_model.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final LocalStorageDatasource _datasource;

  ItineraryRepositoryImpl(this._datasource);

  @override
  Future<List<Trip>> getTrips() async {
    return await _datasource.getTrips();
  }

  @override
  Future<Trip?> getTripById(String id) async {
    return await _datasource.getTripById(id);
  }

  @override
  Future<void> createTrip(Trip trip) async {
    await _datasource.insertTrip(TripModel.fromEntity(trip));
  }

  @override
  Future<List<Activity>> getActivitiesForTrip(String tripId) async {
    return await _datasource.getActivitiesForTrip(tripId);
  }

  @override
  Future<void> addActivity(Activity activity) async {
    await _datasource.insertActivity(ActivityModel.fromEntity(activity));
  }

  @override
  Future<void> toggleActivityCompleted(
    String activityId,
    bool isCompleted,
  ) async {
    await _datasource.updateActivityStatus(activityId, isCompleted);
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    await _datasource.deleteActivity(activityId);
  }

  @override
  Future<List<Waypoint>> getWaypointsForTrip(String tripId) async {
    return await _datasource.getWaypointsForTrip(tripId);
  }

  @override
  Future<Trip> generateAiTrip({
    required String destination,
    required int durationDays,
    required String pace,
    required String budgetTier,
  }) async {
    final tripId = 'trip_${DateTime.now().millisecondsSinceEpoch}';
    double dailyCost = 350.0;
    if (budgetTier == 'Backpacker') dailyCost = 90.0;
    if (budgetTier == 'Balanced Explorer') dailyCost = 280.0;
    if (budgetTier == 'Luxury Alpine' || budgetTier == 'Premium Executive') {
      dailyCost = 650.0;
    }

    final totalBudget = dailyCost * durationDays;

    String imageAsset = 'assets/images/karakoram_hunza.png';
    final lowerDest = destination.toLowerCase();
    if (lowerDest.contains('japan') || lowerDest.contains('tokyo')) {
      imageAsset = 'assets/images/tokyo_shibuya.png';
    } else if (lowerDest.contains('kyoto')) {
      imageAsset = 'assets/images/kyoto_old_town.png';
    } else if (lowerDest.contains('swiss') || lowerDest.contains('alps')) {
      imageAsset = 'assets/images/swiss_interlaken.png';
    } else if (lowerDest.contains('istanbul') || lowerDest.contains('turkey')) {
      imageAsset = 'assets/images/istanbul_bosphorus.png';
    }

    final newTrip = Trip(
      id: tripId,
      title: '$durationDays-Day $destination Expedition',
      destination: destination,
      durationDays: durationDays,
      pace: pace,
      budgetTier: budgetTier,
      totalBudgetUsd: totalBudget,
      imageAsset: imageAsset,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await createTrip(newTrip);

    // Synthesize realistic activities and waypoints for each day
    final baseLat = 35.5 + (destination.hashCode % 100) * 0.05;
    final baseLon = 74.0 + (destination.hashCode % 100) * 0.08;

    for (int day = 1; day <= durationDays; day++) {
      final act1 = Activity(
        id: '${tripId}_d${day}_act1',
        tripId: tripId,
        dayNumber: day,
        timeSlot: '08:30 - 11:00',
        title: 'Morning Exploration of $destination Heritage Hub',
        description:
            'Curated architectural walkthrough and cultural immersion.',
        category: day == 1 ? 'Transit' : 'Landmark',
        costUsd: (dailyCost * 0.25).roundToDouble(),
        isCompleted: day == 1,
        latitude: baseLat + (day * 0.015),
        longitude: baseLon + (day * 0.018),
      );
      final act2 = Activity(
        id: '${tripId}_d${day}_act2',
        tripId: tripId,
        dayNumber: day,
        timeSlot: '12:30 - 14:00',
        title: 'Artisanal Gastronomy & Regional Tasting',
        description:
            'Sample authentic regional delicacies and organic refreshments.',
        category: 'Dining',
        costUsd: (dailyCost * 0.20).roundToDouble(),
        isCompleted: false,
        latitude: baseLat + (day * 0.020),
        longitude: baseLon + (day * 0.022),
      );
      final act3 = Activity(
        id: '${tripId}_d${day}_act3',
        tripId: tripId,
        dayNumber: day,
        timeSlot: '15:30 - 18:30',
        title: 'Panoramic Sunset Observation Leg',
        description:
            'Vantage point summit hike with aerial photography angles.',
        category: 'Landmark',
        costUsd: (dailyCost * 0.15).roundToDouble(),
        isCompleted: false,
        latitude: baseLat + (day * 0.028),
        longitude: baseLon + (day * 0.030),
      );

      await addActivity(act1);
      await addActivity(act2);
      await addActivity(act3);

      final waypoint = Waypoint(
        id: '${tripId}_wp_d$day',
        tripId: tripId,
        dayNumber: day,
        name: '$destination Sector $day Checkpoint',
        latitude: baseLat + (day * 0.020),
        longitude: baseLon + (day * 0.022),
        category: day == 1 ? 'Transit Hubs' : 'Landmarks',
        altitudeMeters: 1800.0 + (day * 150.0),
        localTips: 'Maintain hydration and carry offline digital pass records.',
        transitDurationMins: 35 + (day * 5),
      );
      await _datasource.insertWaypoint(WaypointModel.fromEntity(waypoint));
    }

    return newTrip;
  }
}

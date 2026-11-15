import '../entities/activity.dart';
import '../entities/trip.dart';
import '../entities/waypoint.dart';

abstract class ItineraryRepository {
  Future<List<Trip>> getTrips();
  Future<Trip?> getTripById(String id);
  Future<void> createTrip(Trip trip);
  Future<List<Activity>> getActivitiesForTrip(String tripId);
  Future<void> addActivity(Activity activity);
  Future<void> toggleActivityCompleted(String activityId, bool isCompleted);
  Future<void> deleteActivity(String activityId);
  Future<List<Waypoint>> getWaypointsForTrip(String tripId);
  Future<Trip> generateAiTrip({
    required String destination,
    required int durationDays,
    required String pace,
    required String budgetTier,
  });
}

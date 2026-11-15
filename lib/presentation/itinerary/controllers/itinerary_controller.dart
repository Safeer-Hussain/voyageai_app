import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/trip.dart';
import '../../../domain/entities/waypoint.dart';
import '../../../domain/repositories/itinerary_repository.dart';

class ItineraryController extends GetxController {
  final ItineraryRepository _repository;
  final SharedPreferences _prefs;

  ItineraryController(this._repository, this._prefs);

  final RxList<Trip> trips = <Trip>[].obs;
  final Rxn<Trip> activeTrip = Rxn<Trip>();
  final RxList<Activity> activities = <Activity>[].obs;
  final RxList<Waypoint> waypoints = <Waypoint>[].obs;

  final RxInt selectedDay = 1.obs;
  final RxString filterCategory = 'All'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      final loadedTrips = await _repository.getTrips();
      trips.assignAll(loadedTrips);

      final savedTripId = _prefs.getString(AppConstants.keyActiveTripId);
      if (savedTripId != null && trips.any((t) => t.id == savedTripId)) {
        activeTrip.value = trips.firstWhere((t) => t.id == savedTripId);
      } else if (trips.isNotEmpty) {
        activeTrip.value = trips.first;
        _prefs.setString(AppConstants.keyActiveTripId, trips.first.id);
      }

      if (activeTrip.value != null) {
        await loadActivitiesAndWaypoints(activeTrip.value!.id);
      }
    } catch (_) {
      // Error handling via AppFeedback
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchTrip(String tripId) async {
    if (activeTrip.value?.id == tripId) return;
    final trip = trips.firstWhereOrNull((t) => t.id == tripId);
    if (trip != null) {
      activeTrip.value = trip;
      selectedDay.value = 1;
      _prefs.setString(AppConstants.keyActiveTripId, trip.id);
      await loadActivitiesAndWaypoints(trip.id);
      AppFeedback.showInfo(
        title: 'Trip Switched',
        message: 'Active expedition set to ${trip.title}',
      );
    }
  }

  Future<void> loadActivitiesAndWaypoints(String tripId) async {
    final loadedActivities = await _repository.getActivitiesForTrip(tripId);
    activities.assignAll(loadedActivities);

    final loadedWaypoints = await _repository.getWaypointsForTrip(tripId);
    waypoints.assignAll(loadedWaypoints);
  }

  void selectDay(int day) {
    selectedDay.value = day;
  }

  void setFilterCategory(String category) {
    filterCategory.value = category;
  }

  List<Activity> get currentDayActivities {
    return activities.where((act) {
      final matchesDay = act.dayNumber == selectedDay.value;
      final matchesCategory =
          filterCategory.value == 'All' ||
          act.category.toLowerCase() == filterCategory.value.toLowerCase();
      return matchesDay && matchesCategory;
    }).toList();
  }

  double get tripCompletionPercentage {
    if (activities.isEmpty) return 0.0;
    final completedCount = activities.where((a) => a.isCompleted).length;
    return completedCount / activities.length;
  }

  Future<void> toggleActivityCompleted(String activityId) async {
    final index = activities.indexWhere((a) => a.id == activityId);
    if (index != -1) {
      final current = activities[index];
      final updated = current.copyWith(isCompleted: !current.isCompleted);
      activities[index] = updated;
      activities.refresh();

      await _repository.toggleActivityCompleted(
        activityId,
        updated.isCompleted,
      );
    }
  }

  Future<bool> addActivity({
    required int dayNumber,
    required String timeSlot,
    required String title,
    required String description,
    required String category,
    required double costUsd,
    required double latitude,
    required double longitude,
  }) async {
    if (activeTrip.value == null) return false;

    final newActivity = Activity(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      tripId: activeTrip.value!.id,
      dayNumber: dayNumber,
      timeSlot: timeSlot,
      title: title,
      description: description,
      category: category,
      costUsd: costUsd,
      isCompleted: false,
      latitude: latitude,
      longitude: longitude,
    );

    activities.add(newActivity);
    activities.refresh();
    await _repository.addActivity(newActivity);

    AppFeedback.showSuccess(
      title: 'Activity Scheduled',
      message: '$title has been added to Day $dayNumber.',
    );
    return true;
  }

  Future<void> generateAiTrip({
    required String destination,
    required int durationDays,
    required String pace,
    required String budgetTier,
  }) async {
    isLoading.value = true;
    try {
      final newTrip = await _repository.generateAiTrip(
        destination: destination,
        durationDays: durationDays,
        pace: pace,
        budgetTier: budgetTier,
      );

      trips.add(newTrip);
      activeTrip.value = newTrip;
      selectedDay.value = 1;
      _prefs.setString(AppConstants.keyActiveTripId, newTrip.id);

      await loadActivitiesAndWaypoints(newTrip.id);

      AppFeedback.showSuccess(
        title: 'AI Expedition Generated',
        message: 'Synthesized $durationDays-day route for $destination.',
      );
    } catch (_) {
      AppFeedback.showError(
        title: 'Generation Failed',
        message: 'Could not synthesize itinerary. Please retry.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> copyPlanToClipboard() async {
    if (activeTrip.value == null) return;
    final trip = activeTrip.value!;
    final buffer = StringBuffer();
    buffer.writeln('VOYAGEAI EXPEDITION DOSSIER');
    buffer.writeln('Title: ${trip.title}');
    buffer.writeln('Destination: ${trip.destination}');
    buffer.writeln('Duration: ${trip.durationDays} Days | Pace: ${trip.pace}');
    buffer.writeln('Total Budget: \$${trip.totalBudgetUsd.toStringAsFixed(2)}');
    buffer.writeln('--------------------------------------------------');

    for (int day = 1; day <= trip.durationDays; day++) {
      buffer.writeln('\nDAY $day ITINERARY:');
      final dayActs = activities.where((a) => a.dayNumber == day);
      if (dayActs.isEmpty) {
        buffer.writeln('  Rest and acclimatization day.');
      } else {
        for (final a in dayActs) {
          final status = a.isCompleted ? '[COMPLETED]' : '[SCHEDULED]';
          buffer.writeln('  - ${a.timeSlot} | ${a.title} ($status)');
          buffer.writeln(
            '    Category: ${a.category} | Est: \$${a.costUsd.toStringAsFixed(0)}',
          );
        }
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppFeedback.showSuccess(
      title: 'Itinerary Copied',
      message: 'Expedition plan copied to system clipboard.',
    );
  }

  Future<void> exportJsonDossier() async {
    if (activeTrip.value == null) return;
    final trip = activeTrip.value!;
    final dossier = {
      'expedition_id': trip.id,
      'title': trip.title,
      'destination': trip.destination,
      'duration_days': trip.durationDays,
      'pace': trip.pace,
      'budget_tier': trip.budgetTier,
      'total_budget_usd': trip.totalBudgetUsd,
      'activities': activities
          .map(
            (a) => {
              'day': a.dayNumber,
              'slot': a.timeSlot,
              'title': a.title,
              'category': a.category,
              'cost_usd': a.costUsd,
              'is_completed': a.isCompleted,
              'latitude': a.latitude,
              'longitude': a.longitude,
            },
          )
          .toList(),
      'waypoints': waypoints
          .map(
            (w) => {
              'day': w.dayNumber,
              'name': w.name,
              'latitude': w.latitude,
              'longitude': w.longitude,
              'category': w.category,
              'altitude_m': w.altitudeMeters,
            },
          )
          .toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(dossier);
    await Clipboard.setData(ClipboardData(text: jsonString));
    AppFeedback.showSuccess(
      title: 'JSON Dossier Exported',
      message: 'Full trip JSON structure copied to clipboard.',
    );
  }
}

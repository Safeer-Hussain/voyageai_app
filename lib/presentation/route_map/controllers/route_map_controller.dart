import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/haversine_calculator.dart';
import '../../../domain/entities/waypoint.dart';
import '../../../domain/repositories/itinerary_repository.dart';

class RouteMapController extends GetxController {
  final ItineraryRepository _repository;

  RouteMapController(this._repository);

  final RxList<Waypoint> waypoints = <Waypoint>[].obs;
  final Rxn<Waypoint> selectedWaypoint = Rxn<Waypoint>();
  final RxString selectedCategory = 'All Stops'.obs;
  final RxInt selectedDay = 0.obs; // 0 means all days
  final Rxn<Waypoint> highlightedLegWaypoint = Rxn<Waypoint>();

  MapController? mapController;

  static const List<String> categories = [
    'All Stops',
    'Landmarks',
    'Accommodations',
    'Dining',
    'Transit Hubs',
  ];

  Future<void> loadWaypoints(String tripId) async {
    final loaded = await _repository.getWaypointsForTrip(tripId);
    waypoints.assignAll(loaded);
    if (waypoints.isNotEmpty) {
      selectedWaypoint.value = waypoints.first;
    } else {
      selectedWaypoint.value = null;
    }
  }

  void selectWaypoint(Waypoint waypoint) {
    selectedWaypoint.value = waypoint;
    if (mapController != null) {
      mapController!.move(LatLng(waypoint.latitude, waypoint.longitude), 13.5);
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  void filterByDay(int day) {
    selectedDay.value = day;
  }

  void highlightLeg(Waypoint waypoint) {
    highlightedLegWaypoint.value = waypoint;
    if (mapController != null) {
      mapController!.move(LatLng(waypoint.latitude, waypoint.longitude), 14.0);
    }
  }

  void recenterMap() {
    if (visibleWaypoints.isNotEmpty && mapController != null) {
      final first = visibleWaypoints.first;
      mapController!.move(LatLng(first.latitude, first.longitude), 10.5);
    }
  }

  List<Waypoint> get visibleWaypoints {
    return waypoints.where((wp) {
      final matchesCategory =
          selectedCategory.value == 'All Stops' ||
          wp.category.toLowerCase() == selectedCategory.value.toLowerCase();
      final matchesDay =
          selectedDay.value == 0 || wp.dayNumber == selectedDay.value;
      return matchesCategory && matchesDay;
    }).toList();
  }

  List<LatLng> get routeCoordinates {
    return visibleWaypoints
        .map((wp) => LatLng(wp.latitude, wp.longitude))
        .toList();
  }

  double calculateDistanceFromPrevious(Waypoint waypoint) {
    final index = visibleWaypoints.indexOf(waypoint);
    if (index <= 0) return 0.0;
    final prev = visibleWaypoints[index - 1];
    return HaversineCalculator.calculateDistanceKm(
      LatLng(prev.latitude, prev.longitude),
      LatLng(waypoint.latitude, waypoint.longitude),
    );
  }
}

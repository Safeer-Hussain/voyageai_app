import '../../domain/entities/waypoint.dart';

class WaypointModel extends Waypoint {
  const WaypointModel({
    required super.id,
    required super.tripId,
    required super.dayNumber,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.category,
    required super.altitudeMeters,
    required super.localTips,
    required super.transitDurationMins,
  });

  factory WaypointModel.fromMap(Map<String, dynamic> map) {
    return WaypointModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      dayNumber: (map['day_number'] as num).toInt(),
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      category: map['category'] as String,
      altitudeMeters: (map['altitude_meters'] as num).toDouble(),
      localTips: map['local_tips'] as String,
      transitDurationMins: (map['transit_duration_mins'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'day_number': dayNumber,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'altitude_meters': altitudeMeters,
      'local_tips': localTips,
      'transit_duration_mins': transitDurationMins,
    };
  }

  factory WaypointModel.fromEntity(Waypoint waypoint) {
    return WaypointModel(
      id: waypoint.id,
      tripId: waypoint.tripId,
      dayNumber: waypoint.dayNumber,
      name: waypoint.name,
      latitude: waypoint.latitude,
      longitude: waypoint.longitude,
      category: waypoint.category,
      altitudeMeters: waypoint.altitudeMeters,
      localTips: waypoint.localTips,
      transitDurationMins: waypoint.transitDurationMins,
    );
  }
}

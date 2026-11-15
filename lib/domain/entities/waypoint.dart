class Waypoint {
  final String id;
  final String tripId;
  final int dayNumber;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final double altitudeMeters;
  final String localTips;
  final int transitDurationMins;

  const Waypoint({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.altitudeMeters,
    required this.localTips,
    required this.transitDurationMins,
  });

  Waypoint copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    String? name,
    double? latitude,
    double? longitude,
    String? category,
    double? altitudeMeters,
    String? localTips,
    int? transitDurationMins,
  }) {
    return Waypoint(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      localTips: localTips ?? this.localTips,
      transitDurationMins: transitDurationMins ?? this.transitDurationMins,
    );
  }
}

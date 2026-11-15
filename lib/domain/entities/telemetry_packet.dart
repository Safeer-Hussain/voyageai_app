class TelemetryPacket {
  final double altitudeMeters;
  final double altitudeFeet;
  final double pressureHpa;
  final double azimuthDegrees;
  final double temperatureCelsius;
  final double uvIndex;
  final double gpsAccuracyMeters;
  final int timestamp;

  const TelemetryPacket({
    required this.altitudeMeters,
    required this.altitudeFeet,
    required this.pressureHpa,
    required this.azimuthDegrees,
    required this.temperatureCelsius,
    required this.uvIndex,
    required this.gpsAccuracyMeters,
    required this.timestamp,
  });

  factory TelemetryPacket.fromMap(Map<String, dynamic> map) {
    return TelemetryPacket(
      altitudeMeters: (map['altitudeMeters'] as num?)?.toDouble() ?? 2450.0,
      altitudeFeet: (map['altitudeFeet'] as num?)?.toDouble() ?? 8038.0,
      pressureHpa: (map['pressureHpa'] as num?)?.toDouble() ?? 755.0,
      azimuthDegrees: (map['azimuthDegrees'] as num?)?.toDouble() ?? 38.0,
      temperatureCelsius:
          (map['temperatureCelsius'] as num?)?.toDouble() ?? 12.0,
      uvIndex: (map['uvIndex'] as num?)?.toDouble() ?? 6.0,
      gpsAccuracyMeters: (map['gpsAccuracyMeters'] as num?)?.toDouble() ?? 3.5,
      timestamp:
          (map['timestamp'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}

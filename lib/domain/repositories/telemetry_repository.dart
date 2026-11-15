import '../entities/telemetry_packet.dart';

abstract class TelemetryRepository {
  Stream<TelemetryPacket> get telemetryStream;
  Future<Map<String, dynamic>> calibrateAltimeter({double referenceAltitude});
  Future<Map<String, dynamic>> triggerOfflineSosBeacon({
    required double latitude,
    required double longitude,
  });
  Future<Map<String, dynamic>> fetchLocalWeatherAdvisory({String location});
}

import '../../core/platform/telemetry_bridge.dart';
import '../../domain/entities/telemetry_packet.dart';
import '../../domain/repositories/telemetry_repository.dart';

class TelemetryRepositoryImpl implements TelemetryRepository {
  final TelemetryBridge _bridge;

  TelemetryRepositoryImpl(this._bridge);

  @override
  Stream<TelemetryPacket> get telemetryStream {
    return _bridge.telemetryStream.map((map) => TelemetryPacket.fromMap(map));
  }

  @override
  Future<Map<String, dynamic>> calibrateAltimeter({
    double referenceAltitude = 2450.0,
  }) async {
    return await _bridge.calibrateAltimeter(
      referenceAltitude: referenceAltitude,
    );
  }

  @override
  Future<Map<String, dynamic>> triggerOfflineSosBeacon({
    required double latitude,
    required double longitude,
  }) async {
    return await _bridge.triggerOfflineSosBeacon(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<Map<String, dynamic>> fetchLocalWeatherAdvisory({
    String location = 'Alpine Base',
  }) async {
    return await _bridge.fetchLocalWeatherAdvisory(location: location);
  }
}

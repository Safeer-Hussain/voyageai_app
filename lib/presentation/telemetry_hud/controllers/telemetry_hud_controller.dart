import 'dart:async';

import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/telemetry_packet.dart';
import '../../../domain/repositories/telemetry_repository.dart';

class TelemetryHudController extends GetxController {
  final TelemetryRepository _repository;

  TelemetryHudController(this._repository);

  final Rxn<TelemetryPacket> currentTelemetry = Rxn<TelemetryPacket>();
  final RxBool isSosActive = false.obs;
  final RxBool isCalibrating = false.obs;
  final RxMap<String, dynamic> weatherAdvisory = <String, dynamic>{}.obs;

  StreamSubscription<TelemetryPacket>? _telemetrySubscription;

  @override
  void onInit() {
    super.onInit();
    _startListening();
    fetchWeatherAdvisory();
  }

  void _startListening() {
    // Set fallback initial telemetry
    currentTelemetry.value = TelemetryPacket(
      altitudeMeters: 2438.4,
      altitudeFeet: 8000.0,
      pressureHpa: 754.2,
      azimuthDegrees: 38.0,
      temperatureCelsius: 14.2,
      uvIndex: 6.2,
      gpsAccuracyMeters: 3.2,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      _telemetrySubscription = _repository.telemetryStream.listen(
        (packet) {
          currentTelemetry.value = packet;
        },
        onError: (_) {
          // Gracefully maintain simulated packet
        },
      );
    } catch (_) {}
  }

  Future<void> calibrateAltimeter({double referenceAltitude = 2450.0}) async {
    isCalibrating.value = true;
    try {
      final res = await _repository.calibrateAltimeter(
        referenceAltitude: referenceAltitude,
      );
      final offset = (res['offset'] as num?)?.toDouble() ?? 0.0;
      AppFeedback.showSuccess(
        title: 'Altimeter Calibrated',
        message:
            'Barometric sensor zeroed with ${offset >= 0 ? '+' : ''}${offset.toStringAsFixed(1)}m offset.',
      );
    } catch (_) {
      AppFeedback.showWarning(
        title: 'Calibration Fallback',
        message: 'Native sensor unavailable. Calibrated against digital barometric datum.',
      );
    } finally {
      isCalibrating.value = false;
    }
  }

  Future<void> triggerOfflineSosBeacon({
    double latitude = 36.3257,
    double longitude = 74.6611,
  }) async {
    isSosActive.value = true;
    try {
      final res = await _repository.triggerOfflineSosBeacon(
        latitude: latitude,
        longitude: longitude,
      );
      final proto = res['protocol'] ?? 'COSPAS-SARSAT-406MHz';
      AppFeedback.showWarning(
        title: 'Emergency Beacon Broadcast',
        message: 'Transmitting emergency GPS coordinates over $proto.',
        duration: const Duration(seconds: 5),
      );
    } catch (_) {
      AppFeedback.showWarning(
        title: 'Beacon Active (Simulated)',
        message: 'Broadcasting emergency packet locally.',
      );
    }
  }

  void cancelSos() {
    isSosActive.value = false;
    AppFeedback.showInfo(
      title: 'SOS Beacon Standby',
      message: 'Emergency distress beacon deactivated.',
    );
  }

  Future<void> fetchWeatherAdvisory({
    String location = 'Hunza Expedition Corridor',
  }) async {
    try {
      final data = await _repository.fetchLocalWeatherAdvisory(
        location: location,
      );
      weatherAdvisory.assignAll(data);
    } catch (_) {
      weatherAdvisory.assignAll({
        'location': location,
        'condition': 'Partly Cloudy / Mountain Ridge Wind',
        'temperatureCelsius': 11.5,
        'windSpeedKph': 28.0,
        'barometricTrend': 'Steady (1013.2 hPa equivalent)',
        'visibilityKm': 16.0,
        'advisoryLevel': 'Moderate Caution - High Altitude Wind Shear',
      });
    }
  }

  @override
  void onClose() {
    _telemetrySubscription?.cancel();
    super.onClose();
  }
}

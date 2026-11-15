import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/telemetry_hud_controller.dart';
import 'compass_rose_painter.dart';

class TelemetryHudView extends StatelessWidget {
  const TelemetryHudView({super.key});

  @override
  Widget build(BuildContext context) {
    final telemetryCtrl = Get.find<TelemetryHudController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Obx(() {
        final telemetry = telemetryCtrl.currentTelemetry.value;
        final azimuth = telemetry?.azimuthDegrees ?? 0.0;
        final altitudeM = telemetry?.altitudeMeters ?? 2450.0;
        final altitudeFt = telemetry?.altitudeFeet ?? 8038.0;
        final pressure = telemetry?.pressureHpa ?? 755.0;
        final temp = telemetry?.temperatureCelsius ?? 12.0;
        final uv = telemetry?.uvIndex ?? 6.0;
        final gpsAccuracy = telemetry?.gpsAccuracyMeters ?? 3.5;
        final weather = telemetryCtrl.weatherAdvisory;

        final compassWidget = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 210,
                height: 210,
                child: CustomPaint(
                  painter: CompassRosePainter(
                    azimuthDegrees: azimuth,
                    primaryColor: colorScheme.primary,
                    secondaryColor: colorScheme.secondary,
                    outlineColor: colorScheme.outline,
                    textColor: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${azimuth.toStringAsFixed(1)}° ${_getHeadingDesignation(azimuth)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'MAGNETIC AZIMUTH HEADING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );

        final telemetryStatsGrid = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryCard(
                    title: 'BAROMETRIC ALTITUDE',
                    value: '${altitudeM.toStringAsFixed(1)} m',
                    subtitle: '${altitudeFt.toStringAsFixed(0)} ft AMSL',
                    icon: Icons.terrain,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTelemetryCard(
                    title: 'PRESSURE (hPa)',
                    value: pressure.toStringAsFixed(1),
                    subtitle: 'QNH Local Datum',
                    icon: Icons.speed,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryCard(
                    title: 'TEMPERATURE',
                    value: '${temp.toStringAsFixed(1)} °C',
                    subtitle: 'Alpine Ambient',
                    icon: Icons.thermostat,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTelemetryCard(
                    title: 'UV INDEX',
                    value: uv.toStringAsFixed(1),
                    subtitle: 'High Glare Level',
                    icon: Icons.wb_sunny,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTelemetryCard(
                    title: 'GPS ACCURACY',
                    value: '±${gpsAccuracy.toStringAsFixed(1)}m',
                    subtitle: 'Offline Fix',
                    icon: Icons.gps_fixed,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        );

        final advisoryAndActions = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (weather['advisoryLevel'] as String?) ??
                                'Field Weather Telemetry Advisory',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${weather['location'] ?? 'Alpine Zone'}: ${weather['condition'] ?? 'Clear'} • Wind: ${weather['windSpeedKph'] ?? 15} km/h • Visibility: ${weather['visibilityKm'] ?? 10} km',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => telemetryCtrl.calibrateAltimeter(),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Calibrate Altimeter'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      if (telemetryCtrl.isSosActive.value) {
                        telemetryCtrl.cancelSos();
                      } else {
                        telemetryCtrl.triggerOfflineSosBeacon();
                      }
                    },
                    icon: Icon(
                      telemetryCtrl.isSosActive.value
                          ? Icons.cancel
                          : Icons.emergency_share,
                      size: 16,
                    ),
                    label: Text(
                      telemetryCtrl.isSosActive.value
                          ? 'Cancel SOS'
                          : 'SOS Beacon',
                      style: TextStyle(
                        color: telemetryCtrl.isSosActive.value
                            ? colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        if (isLandscape) {
          return Row(
            children: [
              SizedBox(
                width: 280,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: compassWidget,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      telemetryStatsGrid,
                      const SizedBox(height: 12),
                      advisoryAndActions,
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              compassWidget,
              const SizedBox(height: 20),
              telemetryStatsGrid,
              const SizedBox(height: 14),
              advisoryAndActions,
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHeadingDesignation(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'N';
    if (deg >= 22.5 && deg < 67.5) return 'NE';
    if (deg >= 67.5 && deg < 112.5) return 'E';
    if (deg >= 112.5 && deg < 157.5) return 'SE';
    if (deg >= 157.5 && deg < 202.5) return 'S';
    if (deg >= 202.5 && deg < 247.5) return 'SW';
    if (deg >= 247.5 && deg < 292.5) return 'W';
    return 'NW';
  }
}

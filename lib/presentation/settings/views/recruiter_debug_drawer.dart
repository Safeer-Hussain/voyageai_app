import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../di/service_locator.dart';
import '../../document_vault/controllers/document_vault_controller.dart';
import '../../shell/controllers/navigation_controller.dart';
import '../../telemetry_hud/controllers/telemetry_hud_controller.dart';

class RecruiterDebugDrawer extends StatefulWidget {
  const RecruiterDebugDrawer({super.key});

  @override
  State<RecruiterDebugDrawer> createState() => _RecruiterDebugDrawerState();
}

class _RecruiterDebugDrawerState extends State<RecruiterDebugDrawer> {
  final SharedPreferences _prefs = sl<SharedPreferences>();
  late double _latency;
  late bool _force503;
  late bool _simulatedOffline;

  @override
  void initState() {
    super.initState();
    _latency = (_prefs.getInt(AppConstants.keySimulatedLatencyMs) ?? 500)
        .toDouble();
    _force503 = _prefs.getBool(AppConstants.keyForce503Errors) ?? false;
    _simulatedOffline =
        _prefs.getBool(AppConstants.keyOfflineSimulated) ?? false;
  }

  void _injectGateChangeAlert() {
    try {
      final docCtrl = Get.find<DocumentVaultController>();
      if (docCtrl.documents.isNotEmpty) {
        final firstDoc = docCtrl.documents.first;
        final updatedDoc = firstDoc.copyWith(
          gate: 'B18 (UPDATED)',
          notes:
              'Flight gate adjusted from B4 to B18 due to terminal congestion.',
        );
        final index = docCtrl.documents.indexWhere((d) => d.id == firstDoc.id);
        if (index != -1) {
          docCtrl.documents[index] = updatedDoc;
          docCtrl.documents.refresh();
        }
      }
    } catch (_) {}

    AppFeedback.showWarning(
      title: 'Gate Change Injected',
      message:
          'Flight PK-451 departure gate updated to B18. Pass card refreshed.',
    );
  }

  void _injectWeatherAdvisoryAlert() {
    try {
      final telemetryCtrl = Get.find<TelemetryHudController>();
      telemetryCtrl.weatherAdvisory.assignAll({
        'location': 'Karakoram Pass Summit',
        'condition': 'Severe Ridge Blizzard Warning',
        'temperatureCelsius': -8.4,
        'windSpeedKph': 64.0,
        'barometricTrend': 'Rapid Fall (988.0 hPa)',
        'visibilityKm': 2.1,
        'advisoryLevel': 'URGENT CAUTION - High Altitude Wind Gale',
      });
    } catch (_) {}

    AppFeedback.showError(
      title: 'Weather Advisory Injected',
      message:
          'Severe Blizzard warning injected into Expedition Telemetry HUD.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.terminal, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'RECRUITER DEBUG SUITE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Live fault injection, simulated latency & offline telemetry controls.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SIMULATED LATENCY (${_latency.round()} MS)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.primary,
                ),
              ),
              Slider(
                value: _latency,
                min: 400,
                max: 850,
                divisions: 9,
                label: '${_latency.round()} ms',
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                onChanged: (val) {
                  setState(() => _latency = val);
                  _prefs.setInt(
                    AppConstants.keySimulatedLatencyMs,
                    val.round(),
                  );
                },
              ),
              const Divider(height: 32),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Force HTTP 503 Maintenance Errors',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Simulates server downtime on all Dio network interceptor requests to trigger retry views.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _force503,
                activeColor: colorScheme.error,
                onChanged: (val) {
                  setState(() => _force503 = val);
                  _prefs.setBool(AppConstants.keyForce503Errors, val);
                  AppFeedback.showInfo(
                    title: 'HTTP 503 Override',
                    message: val
                        ? 'Dio interceptor will reject requests with 503.'
                        : 'Normal 200 responses restored.',
                  );
                },
              ),
              const Divider(height: 32),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Simulate Offline Roaming Mode',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Activates the top roaming banner and enforces local SQLite query resolution.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _simulatedOffline,
                activeColor: colorScheme.secondary,
                onChanged: (val) {
                  setState(() => _simulatedOffline = val);
                  _prefs.setBool(AppConstants.keyOfflineSimulated, val);
                  try {
                    Get.find<NavigationController>().toggleSimulatedOffline(
                      val,
                    );
                  } catch (_) {}
                },
              ),
              const Divider(height: 32),
              Text(
                'LIVE EVENT INJECTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _injectGateChangeAlert,
                icon: const Icon(Icons.flight_takeoff, size: 18),
                label: const Text('Inject Flight Gate Change Alert'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: _injectWeatherAdvisoryAlert,
                icon: const Icon(Icons.storm, size: 18),
                label: const Text('Inject High Altitude Storm Advisory'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

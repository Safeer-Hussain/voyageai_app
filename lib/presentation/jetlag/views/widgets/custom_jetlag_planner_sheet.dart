import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/jetlag_controller.dart';

class CustomJetlagPlannerSheet extends StatefulWidget {
  const CustomJetlagPlannerSheet({super.key});

  @override
  State<CustomJetlagPlannerSheet> createState() =>
      _CustomJetlagPlannerSheetState();
}

class _CustomJetlagPlannerSheetState extends State<CustomJetlagPlannerSheet> {
  final _formKey = GlobalKey<FormState>();

  String _originCity = 'New York (JFK)';
  int _originTzOffset = -5;

  String _destinationCity = 'Islamabad (ISB)';
  int _destinationTzOffset = 5;

  DateTime _departureDate = DateTime.now().add(const Duration(days: 2));

  void _onOriginChanged(String? val) {
    if (val != null) {
      final found = JetlagController.majorAirports.firstWhere(
        (a) => a['city'] == val,
        orElse: () => {'tzOffset': 0},
      );
      setState(() {
        _originCity = val;
        _originTzOffset = found['tzOffset'] as int;
      });
    }
  }

  void _onDestChanged(String? val) {
    if (val != null) {
      final found = JetlagController.majorAirports.firstWhere(
        (a) => a['city'] == val,
        orElse: () => {'tzOffset': 0},
      );
      setState(() {
        _destinationCity = val;
        _destinationTzOffset = found['tzOffset'] as int;
      });
    }
  }

  int get _calculatedDiff {
    int diff = _destinationTzOffset - _originTzOffset;
    if (diff > 12) diff -= 24;
    if (diff < -12) diff += 24;
    return diff;
  }

  String get _calculatedDirection =>
      _calculatedDiff >= 0 ? 'Eastward' : 'Westward';

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_originCity == _destinationCity) {
        Get.snackbar(
          'Identical Timezones',
          'Origin and destination cannot be identical.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final ctrl = Get.find<JetlagController>();
      ctrl.generateCustomPlan(
        originCity: _originCity,
        originTzOffset: _originTzOffset,
        destinationCity: _destinationCity,
        destinationTzOffset: _destinationTzOffset,
        departureDate: _departureDate,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diff = _calculatedDiff.abs();
    final direction = _calculatedDirection;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Synthesize Circadian Protocol',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calculate optimal light exposure, melatonin, and sleep shift schedules.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Origin Dropdown
                DropdownButtonFormField<String>(
                  value: _originCity,
                  decoration: const InputDecoration(
                    labelText: 'Departure City / Airport',
                    border: OutlineInputBorder(),
                  ),
                  items: JetlagController.majorAirports.map((item) {
                    final city = item['city'] as String;
                    final tz = item['tzOffset'] as int;
                    return DropdownMenuItem(
                      value: city,
                      child: Text(
                        '$city (UTC${tz >= 0 ? "+" : ""}$tz)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: _onOriginChanged,
                ),
                const SizedBox(height: 14),
                // Destination Dropdown
                DropdownButtonFormField<String>(
                  value: _destinationCity,
                  decoration: const InputDecoration(
                    labelText: 'Arrival Destination / Airport',
                    border: OutlineInputBorder(),
                  ),
                  items: JetlagController.majorAirports.map((item) {
                    final city = item['city'] as String;
                    final tz = item['tzOffset'] as int;
                    return DropdownMenuItem(
                      value: city,
                      child: Text(
                        '$city (UTC${tz >= 0 ? "+" : ""}$tz)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: _onDestChanged,
                ),
                const SizedBox(height: 14),
                // Departure Date Selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Expedition Departure Date',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_departureDate.year}-${_departureDate.month.toString().padLeft(2, '0')}-${_departureDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _departureDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 7),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _departureDate = picked);
                      }
                    },
                    child: const Text('Change Date'),
                  ),
                ),
                const SizedBox(height: 12),
                // Preview summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Calculated $diff-Hour $direction shift. Expected circadian stabilization within ${(diff / 1.5).ceil().clamp(2, 8)} days.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'Generate Sleep Shift Protocol',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

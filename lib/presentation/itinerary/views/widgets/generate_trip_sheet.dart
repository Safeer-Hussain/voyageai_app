import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/itinerary_controller.dart';

class GenerateTripSheet extends StatefulWidget {
  const GenerateTripSheet({super.key});

  @override
  State<GenerateTripSheet> createState() => _GenerateTripSheetState();
}

class _GenerateTripSheetState extends State<GenerateTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _destController = TextEditingController(text: 'Kyoto Cultural Loop');
  int _durationDays = 5;
  String _pace = 'Balanced';
  String _budgetTier = 'Balanced Explorer';

  static const List<String> _paces = ['Relaxed', 'Balanced', 'Packed'];
  static const List<String> _tiers = [
    'Backpacker',
    'Balanced Explorer',
    'Luxury Alpine',
    'Premium Executive',
  ];

  @override
  void dispose() {
    _destController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_formKey.currentState?.validate() ?? false) {
      final ctrl = Get.find<ItineraryController>();
      ctrl.generateAiTrip(
        destination: _destController.text.trim(),
        durationDays: _durationDays,
        pace: _pace,
        budgetTier: _budgetTier,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generate AI Multi-Day Expedition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Synthesizes day-by-day itineraries, waypoints, and expense projections.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destController,
                  decoration: const InputDecoration(
                    labelText: 'Expedition Destination or Route Name',
                    hintText: 'e.g. Swiss Alps Panoramic Rail Loop',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please specify a destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Duration: $_durationDays Days',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _durationDays.toDouble(),
                        min: 2,
                        max: 14,
                        divisions: 12,
                        label: '$_durationDays Days',
                        activeColor: colorScheme.primary,
                        inactiveColor: colorScheme.surfaceContainerHighest,
                        onChanged: (val) {
                          setState(() => _durationDays = val.round());
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _pace,
                  decoration: const InputDecoration(
                    labelText: 'Travel Pace',
                    border: OutlineInputBorder(),
                  ),
                  items: _paces.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _pace = val);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _budgetTier,
                  decoration: const InputDecoration(
                    labelText: 'Budget Tier',
                    border: OutlineInputBorder(),
                  ),
                  items: _tiers.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _budgetTier = val);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.bolt, size: 20),
                  label: const Text(
                    'Synthesize Full Day-by-Day Itinerary',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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

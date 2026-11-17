import 'package:flutter/material.dart';

import '../../../../domain/entities/circadian_protocol.dart';
import '../../controllers/jetlag_controller.dart';

class ShiftDayCard extends StatelessWidget {
  final CircadianShiftDay day;
  final JetlagController ctrl;

  const ShiftDayCard({super.key, required this.day, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = day.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Checkbox + Day Label + Tag
            Row(
              children: [
                Checkbox(
                  value: isDone,
                  activeColor: colorScheme.primary,
                  checkColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (_) => ctrl.toggleCheckpoint(day.dayOffset),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.dayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: isDone
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        day.dayOffset < 0
                            ? 'Pre-Flight Preparation'
                            : (day.dayOffset == 0
                                  ? 'Transit & In-Flight Phase'
                                  : 'Post-Arrival Synchronization'),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDone
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    isDone ? 'COMPLETED' : 'PENDING',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDone
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Target Bedtime & Wakeup
            _buildProtocolRow(
              icon: Icons.bedtime_outlined,
              title: 'Sleep Target',
              detail: '${day.targetBedtime}  •  Wakeup ${day.targetWakeup}',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 6),
            // Light Exposure Window
            _buildProtocolRow(
              icon: Icons.wb_sunny_outlined,
              title: 'Light Exposure',
              detail: day.lightExposureWindow,
              colorScheme: colorScheme,
              highlight: true,
            ),
            const SizedBox(height: 6),
            // Light Avoidance Window
            _buildProtocolRow(
              icon: Icons.dark_mode_outlined,
              title: 'Light Avoidance',
              detail: day.lightAvoidanceWindow,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 6),
            // Caffeine & Stimulants
            _buildProtocolRow(
              icon: Icons.coffee_outlined,
              title: 'Caffeine Cutoff',
              detail: day.caffeineCutoff,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 6),
            // Meal Anchor
            _buildProtocolRow(
              icon: Icons.restaurant_outlined,
              title: 'Meal Timing',
              detail: day.mealAnchor,
              colorScheme: colorScheme,
            ),
            if (day.melatoninWindow != 'None required') ...[
              const SizedBox(height: 6),
              _buildProtocolRow(
                icon: Icons.medication_outlined,
                title: 'Melatonin Window',
                detail: day.melatoninWindow,
                colorScheme: colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolRow({
    required IconData icon,
    required String title,
    required String detail,
    required ColorScheme colorScheme,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: highlight ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: highlight
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            detail,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../controllers/jetlag_controller.dart';

class CircadianClockCockpit extends StatelessWidget {
  final JetlagController ctrl;

  const CircadianClockCockpit({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plan = ctrl.activePlan.value;
    final now = DateTime.now();

    if (plan == null) {
      return const SizedBox.shrink();
    }

    final originTime = ctrl.getOriginTimeString(now);
    final destTime = ctrl.getDestinationTimeString(now);
    final rate = ctrl.adaptationPercentage;
    final isEastward = plan.direction == 'Eastward';

    Color statusColor = colorScheme.primary;
    if (rate >= 0.8) {
      statusColor = colorScheme.secondary;
    } else if (rate < 0.4) {
      statusColor = colorScheme.tertiary;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'CIRCADIAN PACEMAKER COCKPIT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    isEastward ? 'PHASE ADVANCE' : 'PHASE DELAY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Dual Clock Row
            Row(
              children: [
                Expanded(
                  child: _buildClockColumn(
                    label: 'ORIGIN TIME',
                    city: plan.originCity,
                    time: originTime,
                    tzLabel:
                        'UTC${plan.originTzOffset >= 0 ? "+" : ""}${plan.originTzOffset}',
                    colorScheme: colorScheme,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Icon(
                        isEastward ? Icons.east_rounded : Icons.west_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${plan.totalHourShift}h Shift',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildClockColumn(
                    label: 'DESTINATION TIME',
                    city: plan.destinationCity,
                    time: destTime,
                    tzLabel:
                        'UTC${plan.destinationTzOffset >= 0 ? "+" : ""}${plan.destinationTzOffset}',
                    colorScheme: colorScheme,
                    isDestination: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Circadian Adaptation Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          rate >= 0.8
                              ? Icons.check_circle_outline
                              : Icons.timelapse,
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ctrl.statusBadge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${(rate * 100).toStringAsFixed(0)}% Synchronized',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Metric Badges
            Row(
              children: [
                Expanded(
                  child: _buildInfoBadge(
                    icon: Icons.calendar_today_outlined,
                    label: 'Recovery Window',
                    value: '${plan.daysToAdapt} Days',
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInfoBadge(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Light Strategy',
                    value: isEastward ? 'Morning Light' : 'Evening Light',
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInfoBadge(
                    icon: Icons.bedtime_outlined,
                    label: 'Shift Sleep',
                    value: isEastward ? 'Earlier' : 'Later',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockColumn({
    required String label,
    required String city,
    required String time,
    required String tzLabel,
    required ColorScheme colorScheme,
    bool isDestination = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDestination
            ? colorScheme.primaryContainer.withAlpha(40)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDestination
              ? colorScheme.primary.withAlpha(80)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                tzLabel,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: isDestination
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDestination
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
          ),
          Text(
            city,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

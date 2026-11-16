import 'package:flutter/material.dart';

import '../../controllers/packing_checklist_controller.dart';

class BaggageWeightCockpit extends StatelessWidget {
  final PackingChecklistController ctrl;

  const BaggageWeightCockpit({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final packedKg = ctrl.totalPackedWeightKg;
    final allowanceKg = ctrl.selectedAllowanceKg.value;
    final remainingKg = ctrl.remainingAllowanceKg;
    final burnRatio = ctrl.weightBurnRatio;
    final isOverweight = ctrl.isOverweight;
    final isWarning = burnRatio > 0.85 && !isOverweight;

    Color statusColor = colorScheme.primary;
    String statusText = 'WITHIN ALLOWANCE';
    if (isOverweight) {
      statusColor = colorScheme.error;
      statusText = 'OVERWEIGHT SURCHARGE ALERT';
    } else if (isWarning) {
      statusColor = colorScheme.secondary;
      statusText = 'NEARING BAGGAGE LIMIT';
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
                    'BAGGAGE WEIGHT COCKPIT',
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
                InkWell(
                  onTap: ctrl.toggleWeightUnit,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
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
                      'UNIT: ${ctrl.weightUnit.value}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildWeightMetric(
                    'PACKED WEIGHT',
                    ctrl.formatWeight(packedKg),
                    colorScheme.onSurface,
                    colorScheme,
                  ),
                ),
                Expanded(
                  child: _buildWeightMetric(
                    'LIMIT TIER',
                    ctrl.formatWeight(allowanceKg),
                    colorScheme.secondary,
                    colorScheme,
                  ),
                ),
                Expanded(
                  child: _buildWeightMetric(
                    'REMAINING',
                    remainingKg >= 0
                        ? ctrl.formatWeight(remainingKg)
                        : '+${ctrl.formatWeight(remainingKg.abs())} OVER',
                    statusColor,
                    colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: burnRatio,
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
                      horizontal: 6,
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
                          isOverweight
                              ? Icons.error_outline
                              : (isWarning
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline),
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            statusText,
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
                  '${(ctrl.packingProgressPercentage * 100).toStringAsFixed(0)}% Packed',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Allowance Selectors
            Row(
              children: [
                Expanded(
                  child: _buildAllowanceChip(
                    label: 'Carry-On (7kg)',
                    value: 7.0,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildAllowanceChip(
                    label: 'Checked (23kg)',
                    value: 23.0,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildAllowanceChip(
                    label: 'Expedition (32kg)',
                    value: 32.0,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: ctrl.autoPackEssentials,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, size: 13),
                        SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Auto-Pack',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: ctrl.resetChecklist,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restart_alt, size: 13),
                        SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Reset All',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightMetric(
    String label,
    String value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAllowanceChip({
    required String label,
    required double value,
    required ColorScheme colorScheme,
  }) {
    final isSelected = (ctrl.selectedAllowanceKg.value - value).abs() < 0.1;

    return InkWell(
      onTap: () => ctrl.setAllowance(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

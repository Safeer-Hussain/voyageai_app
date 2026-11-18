import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/currency_cheat_sheet_controller.dart';

class TipCockpit extends StatelessWidget {
  final CurrencyCheatSheetController ctrl;

  const TipCockpit({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final numberFormat = NumberFormat('#,##0.00');

    return Obx(() {
      final calc = ctrl.tipCalculation;
      final activeTarget = ctrl.targetCurrency.value;
      final preset = ctrl.activePreset;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'MULTI-MERCHANT TIP & SPLIT COCKPIT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Merchant Category Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CurrencyCheatSheetController.tipPresets.map((p) {
                    final isSelected =
                        ctrl.selectedCategory.value == p.category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(p.title),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: colorScheme.primaryContainer,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (_) => ctrl.selectCategory(p.category),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Cultural Etiquette Notice Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        preset.etiquetteNotice,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Bill Input Row
              TextFormField(
                initialValue: ctrl.billAmount.value.toStringAsFixed(0),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Bill Amount ($activeTarget)',
                  suffixText: activeTarget,
                  prefixIcon: const Icon(Icons.receipt_outlined, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val) ?? 0.0;
                  ctrl.setBillAmount(parsed);
                },
              ),
              const SizedBox(height: 12),
              // Tip Percentage Quick Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tip Percentage: ${ctrl.selectedTipPercent.value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [0.0, 5.0, 10.0, 12.0, 15.0, 18.0, 20.0, 25.0].map((
                    pct,
                  ) {
                    final isSel =
                        (ctrl.selectedTipPercent.value - pct).abs() < 0.1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text('${pct.toInt()}%'),
                        selected: isSel,
                        showCheckmark: false,
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (_) => ctrl.setTipPercent(pct),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              // Split & Round Up Options
              Row(
                children: [
                  // Split Count Controls
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          Text(
                            'Split: ${ctrl.splitCount.value}x',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => ctrl.setSplitCount(
                                  ctrl.splitCount.value - 1,
                                ),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => ctrl.setSplitCount(
                                  ctrl.splitCount.value + 1,
                                ),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Round Up Button
                  Expanded(
                    child: InkWell(
                      onTap: ctrl.toggleRoundUp,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: ctrl.roundUpToNote.value
                              ? colorScheme.secondaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ctrl.roundUpToNote.value
                                ? colorScheme.secondary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              ctrl.roundUpToNote.value
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 16,
                              color: ctrl.roundUpToNote.value
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Round Up Note',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: ctrl.roundUpToNote.value
                                      ? colorScheme.onSecondaryContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Calculation Summary Cockpit
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withAlpha(80)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      label: 'Tip Gratuity Amount',
                      value:
                          '${numberFormat.format(calc.tipAmount)} $activeTarget',
                      colorScheme: colorScheme,
                      isBold: false,
                    ),
                    if (calc.roundUpDifference > 0) ...[
                      const SizedBox(height: 4),
                      _buildSummaryRow(
                        label: 'Round Up Buffer',
                        value:
                            '+${numberFormat.format(calc.roundUpDifference)} $activeTarget',
                        colorScheme: colorScheme,
                        isBold: false,
                      ),
                    ],
                    const Divider(height: 12),
                    _buildSummaryRow(
                      label: 'Total Bill with Tip',
                      value:
                          '${numberFormat.format(calc.totalWithTip)} $activeTarget',
                      colorScheme: colorScheme,
                      isBold: true,
                      highlightColor: colorScheme.primary,
                    ),
                    if (calc.splitCount > 1) ...[
                      const SizedBox(height: 4),
                      _buildSummaryRow(
                        label: 'Per Person Share (${calc.splitCount}x)',
                        value:
                            '${numberFormat.format(calc.perPersonTotal)} $activeTarget',
                        colorScheme: colorScheme,
                        isBold: true,
                        highlightColor: colorScheme.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required bool isBold,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 12 : 11,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 11.5,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: highlightColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

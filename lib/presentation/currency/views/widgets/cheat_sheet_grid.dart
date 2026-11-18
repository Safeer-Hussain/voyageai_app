import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/currency_cheat_sheet_controller.dart';

class CheatSheetGrid extends StatelessWidget {
  final CurrencyCheatSheetController ctrl;

  const CheatSheetGrid({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final rate = ctrl.currentRate.value;
      final denoms = ctrl.cheatSheetDenominations;
      final isReciprocal = ctrl.isReciprocal.value;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Currency Selector Row
              Row(
                children: [
                  Expanded(
                    child: _buildCurrencyDropdown(
                      label: 'Base Currency',
                      value: ctrl.baseCurrency.value,
                      onChanged: (v) =>
                          v != null ? ctrl.setBaseCurrency(v) : null,
                      colorScheme: colorScheme,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.swap_horiz_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    tooltip: 'Swap Currencies',
                    onPressed: ctrl.switchCurrencies,
                  ),
                  Expanded(
                    child: _buildCurrencyDropdown(
                      label: 'Target Currency',
                      value: ctrl.targetCurrency.value,
                      onChanged: (v) =>
                          v != null ? ctrl.setTargetCurrency(v) : null,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Rate Indicator & Reciprocal Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OFFLINE RATE BENCHMARK',
                            style: TextStyle(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rate != null
                                ? '1 ${ctrl.baseCurrency.value} = ${rate.effectiveRate.toStringAsFixed(2)} ${ctrl.targetCurrency.value}'
                                : 'Rate unavailable',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (ctrl.spreadPercent.value > 0)
                            Text(
                              '+${ctrl.spreadPercent.value.toStringAsFixed(1)}% ATM / Card Exchange Fee Buffer',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: ctrl.toggleReciprocal,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isReciprocal
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isReciprocal
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.compare_arrows_rounded,
                              size: 14,
                              color: isReciprocal
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isReciprocal ? 'INVERTED' : 'STANDARD',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isReciprocal
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Denomination Grid / Table Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'BASE VALUE (${isReciprocal ? ctrl.targetCurrency.value : ctrl.baseCurrency.value})',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'EQUIVALENT (${isReciprocal ? ctrl.baseCurrency.value : ctrl.targetCurrency.value})',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Denominations List
              Column(
                children: denoms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isEven = index % 2 == 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isEven
                          ? colorScheme.surfaceContainerLow
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.formattedBase,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.formattedConverted,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
    required ColorScheme colorScheme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: CurrencyCheatSheetController.supportedCurrencies.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Text(
            c,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

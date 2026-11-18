import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/currency_cheat_sheet_controller.dart';

class QuickReferenceTable extends StatelessWidget {
  final CurrencyCheatSheetController ctrl;

  const QuickReferenceTable({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final rate = ctrl.directExchangeRate;
      final rows = ctrl.cheatSheetRows;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with current cross-rate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CASH CHEAT-SHEET MATRIX',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1 ${ctrl.baseCurrency.value} = ${ctrl.formatAmount(rate)} ${ctrl.targetCurrency.value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.swap_horiz, color: colorScheme.primary),
                    tooltip: 'Swap Currencies',
                    onPressed: ctrl.swapCurrencies,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Column Headers
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
                        'BASE (${ctrl.baseCurrency.value})',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LOCAL (${ctrl.targetCurrency.value})',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Conversion Rows
              ...rows.map((row) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withAlpha(80),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.formattedBase,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.drag_handle,
                        size: 12,
                        color: colorScheme.outlineVariant,
                      ),
                      Expanded(
                        child: Text(
                          row.formattedConverted,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

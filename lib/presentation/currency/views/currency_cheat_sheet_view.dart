import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/currency_cheat_sheet_controller.dart';
import 'widgets/merchant_tip_calculator.dart';
import 'widgets/quick_reference_table.dart';
import 'widgets/rate_override_sheet.dart';

class CurrencyCheatSheetView extends StatelessWidget {
  const CurrencyCheatSheetView({super.key});

  void _showRateOverride(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RateOverrideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CurrencyCheatSheetController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency & Tip Calculator',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Official Rates',
            onPressed: ctrl.resetRates,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_currency_rate_override',
        onPressed: () => _showRateOverride(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.tune, size: 20),
        label: const Text(
          'Calibrate Rate',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.rates.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final currencySelector = _buildCurrencySelectorBar(ctrl, colorScheme);
        final tipCalculatorWidget = MerchantTipCalculator(ctrl: ctrl);
        final cheatSheetWidget = QuickReferenceTable(ctrl: ctrl);
        final historyWidget = _buildHistorySection(ctrl, colorScheme);

        if (isLandscape) {
          return Column(
            children: [
              currencySelector,
              const Divider(height: 1),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 380,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(children: [tipCalculatorWidget]),
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
                            cheatSheetWidget,
                            const SizedBox(height: 10),
                            historyWidget,
                            const SizedBox(height: 72),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              currencySelector,
              const SizedBox(height: 12),
              tipCalculatorWidget,
              const SizedBox(height: 12),
              cheatSheetWidget,
              const SizedBox(height: 12),
              historyWidget,
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrencySelectorBar(
    CurrencyCheatSheetController ctrl,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BASE CURRENCY',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ctrl.baseCurrency.value,
                    isDense: true,
                    dropdownColor: colorScheme.surfaceContainerHighest,
                    items: CurrencyCheatSheetController.availableCurrencies.map(
                      (c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      if (val != null) ctrl.setBaseCurrency(val);
                    },
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LOCAL TARGET',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ctrl.targetCurrency.value,
                    isDense: true,
                    dropdownColor: colorScheme.surfaceContainerHighest,
                    items: CurrencyCheatSheetController.availableCurrencies.map(
                      (c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      if (val != null) ctrl.setTargetCurrency(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    CurrencyCheatSheetController ctrl,
    ColorScheme colorScheme,
  ) {
    final list = ctrl.savedConversions;
    if (list.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'SAVED CONVERSION SNAPSHOTS',
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
            const SizedBox(height: 8),
            ...list.take(5).map((item) {
              final id = item['id'] as int?;
              final baseAmt = (item['base_amount'] as num?)?.toDouble() ?? 0.0;
              final convAmt =
                  (item['converted_amount'] as num?)?.toDouble() ?? 0.0;
              final baseCur = item['base_currency'] as String? ?? '';
              final targetCur = item['target_currency'] as String? ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ctrl.formatAmount(baseAmt)} $baseCur = ${ctrl.formatAmount(convAmt)} $targetCur',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (id != null)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => ctrl.deleteSavedConversion(id),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

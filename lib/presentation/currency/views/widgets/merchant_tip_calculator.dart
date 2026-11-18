import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/merchant_tip.dart';
import '../../controllers/currency_cheat_sheet_controller.dart';

class MerchantTipCalculator extends StatelessWidget {
  final CurrencyCheatSheetController ctrl;

  const MerchantTipCalculator({super.key, required this.ctrl});

  IconData _getMerchantIcon(MerchantType type) {
    switch (type) {
      case MerchantType.dining:
        return Icons.restaurant_outlined;
      case MerchantType.taxi:
        return Icons.local_taxi_outlined;
      case MerchantType.porter:
        return Icons.room_service_outlined;
      case MerchantType.tourGuide:
        return Icons.hiking_outlined;
      case MerchantType.cafe:
        return Icons.local_cafe_outlined;
    }
  }

  String _getMerchantLabel(MerchantType type) {
    switch (type) {
      case MerchantType.dining:
        return 'Dining';
      case MerchantType.taxi:
        return 'Taxi';
      case MerchantType.porter:
        return 'Porter';
      case MerchantType.tourGuide:
        return 'Guide';
      case MerchantType.cafe:
        return 'Cafe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final calc = ctrl.tipCalculation;
      final etiquette = ctrl.tippingEtiquette;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'MULTI-MERCHANT TIP & SPLIT COCKPIT',
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
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      calc.currencyCode,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Merchant Type Chips
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: MerchantType.values.map((type) {
                    final isSelected = ctrl.merchantType.value == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Icon(
                          _getMerchantIcon(type),
                          size: 14,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        label: Text(_getMerchantLabel(type)),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        selectedColor: colorScheme.primaryContainer,
                        backgroundColor: colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onSelected: (_) => ctrl.setMerchantType(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              // Bill Input Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BILL AMOUNT (${ctrl.targetCurrency.value})',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ctrl.formatAmount(ctrl.billAmount.value)} ${ctrl.targetCurrency.value}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick Bill Adders
                  Wrap(
                    spacing: 4,
                    children: [500.0, 1000.0, 5000.0].map((delta) {
                      return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        onPressed: () =>
                            ctrl.setBillAmount(ctrl.billAmount.value + delta),
                        child: Text(
                          '+${delta.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tip Percentage Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIP: ${ctrl.tipPercentage.value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${ctrl.formatAmount(calc.tipAmount)} ${ctrl.targetCurrency.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [0.0, 5.0, 10.0, 15.0, 20.0].map((pct) {
                  final isSelected =
                      (ctrl.tipPercentage.value - pct).abs() < 0.1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: InkWell(
                        onTap: () => ctrl.setTipPercentage(pct),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.secondaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.secondary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Split Travelers Row
              Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Split: ${ctrl.splitCount.value} Traveler${ctrl.splitCount.value > 1 ? "s" : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.outlined(
                    icon: const Icon(Icons.remove, size: 14),
                    visualDensity: VisualDensity.compact,
                    onPressed: ctrl.decrementSplit,
                  ),
                  const SizedBox(width: 4),
                  IconButton.outlined(
                    icon: const Icon(Icons.add, size: 14),
                    visualDensity: VisualDensity.compact,
                    onPressed: ctrl.incrementSplit,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Calculation Output Breakdown Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withAlpha(70)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TOTAL WITH TIP',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${ctrl.formatAmount(calc.totalAmount)} ${calc.currencyCode}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Base Currency Equivalent',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '~ ${ctrl.formatAmount(calc.equivalentBaseTotal)} ${calc.baseCurrencyCode}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (calc.splitCount > 1) ...[
                      const Divider(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'EACH TRAVELER OWES',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${ctrl.formatAmount(calc.perPersonTotal)} ${calc.currencyCode}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Regional Tipping Etiquette Advice Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      etiquette.isTippingCustomary
                          ? Icons.info_outline
                          : Icons.do_not_disturb_on_outlined,
                      size: 15,
                      color: etiquette.isTippingCustomary
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ETIQUETTE: ${etiquette.countryOrCurrency.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: etiquette.isTippingCustomary
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            etiquette.generalGuidance,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Action Button to Save Conversion
              OutlinedButton.icon(
                icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                label: const Text('Save Calculation to Ledger History'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                onPressed: ctrl.saveCurrentConversion,
              ),
            ],
          ),
        ),
      );
    });
  }
}

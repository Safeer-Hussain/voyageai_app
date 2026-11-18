import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/currency_cheat_sheet_controller.dart';

class RateOverrideSheet extends StatefulWidget {
  const RateOverrideSheet({super.key});

  @override
  State<RateOverrideSheet> createState() => _RateOverrideSheetState();
}

class _RateOverrideSheetState extends State<RateOverrideSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rateController;
  late CurrencyCheatSheetController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<CurrencyCheatSheetController>();
    final currentRate = _ctrl.rates[_ctrl.targetCurrency.value] ?? 1.0;
    _rateController = TextEditingController(
      text: currentRate.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _applyFeePercentage(double pct) {
    final current = double.tryParse(_rateController.text) ?? 1.0;
    final adjusted = current * (1.0 + (pct / 100.0));
    _rateController.text = adjusted.toStringAsFixed(2);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newRate = double.tryParse(_rateController.text.trim()) ?? 1.0;
      _ctrl.updateCustomRate(newRate);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final target = _ctrl.targetCurrency.value;

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
                  'Calibrate Street Cash Rate ($target)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust the exchange rate to reflect real street currency booths or bank foreign transaction fee surcharges.',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '1 USD to $target Exchange Rate',
                    hintText: 'e.g. 280.50',
                    suffixText: target,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a valid exchange rate';
                    }
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) {
                      return 'Rate must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Quick Bank Fee Markup (+1% - +3% FX Fee):',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [1.0, 2.0, 3.0].map((fee) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          onPressed: () => _applyFeePercentage(fee),
                          child: Text(
                            '+$fee% Fee',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                    'Save Calibrated Exchange Rate',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.restart_alt, size: 16),
                    label: const Text('Reset to Official Reference Rate'),
                    onPressed: () {
                      _ctrl.resetRates();
                      Navigator.of(context).pop();
                    },
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

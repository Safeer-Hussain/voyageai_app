import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/currency_cheat_sheet_controller.dart';

class RateCalibrationSheet extends StatefulWidget {
  const RateCalibrationSheet({super.key});

  @override
  State<RateCalibrationSheet> createState() => _RateCalibrationSheetState();
}

class _RateCalibrationSheetState extends State<RateCalibrationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rateController;
  late double _spread;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<CurrencyCheatSheetController>();
    final rate = ctrl.currentRate.value?.rate ?? 1.0;
    _rateController = TextEditingController(text: rate.toStringAsFixed(4));
    _spread = ctrl.spreadPercent.value;
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final ctrl = Get.find<CurrencyCheatSheetController>();
      final newRate = double.tryParse(_rateController.text) ?? 1.0;
      ctrl.updateCustomRate(newRate);
      ctrl.setSpreadPercent(_spread);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ctrl = Get.find<CurrencyCheatSheetController>();

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
                  'Calibrate Exchange Rate & Spread',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust the benchmark exchange rate and include ATM or credit card foreign transaction fee buffers.',
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
                    labelText:
                        '1 ${ctrl.baseCurrency.value} in ${ctrl.targetCurrency.value}',
                    suffixText: ctrl.targetCurrency.value,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Enter exchange rate';
                    }
                    final numVal = double.tryParse(val);
                    if (numVal == null || numVal <= 0) {
                      return 'Must be a positive decimal number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bank / ATM Spread Margin:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${_spread.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _spread,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  label: '${_spread.toStringAsFixed(1)}%',
                  activeColor: colorScheme.primary,
                  onChanged: (val) => setState(() => _spread = val),
                ),
                Text(
                  'Typical bank conversion spread: 1.5% to 3.5% above interbank mid-market.',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
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
                    'Save Calibrated Rate',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

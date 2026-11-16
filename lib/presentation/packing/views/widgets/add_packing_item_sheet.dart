import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/packing_checklist_controller.dart';

class AddPackingItemSheet extends StatefulWidget {
  const AddPackingItemSheet({super.key});

  @override
  State<AddPackingItemSheet> createState() => _AddPackingItemSheetState();
}

class _AddPackingItemSheetState extends State<AddPackingItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _weightController = TextEditingController(text: '0.5');

  String _selectedCategory = 'Technical Gear';
  bool _isEssential = true;

  static const List<String> _categories = [
    'Technical Gear',
    'Thermal Apparel',
    'Medical & Health',
    'Field Electronics',
    'Travel Documents',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final ctrl = Get.find<PackingChecklistController>();
      final weight = double.tryParse(_weightController.text.trim()) ?? 0.5;

      ctrl.addItem(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        weightKg: weight,
        isEssential: _isEssential,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  'Add Expedition Gear / Item',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name / Description',
                    hintText: 'e.g. Climbing Harness & Carabiner Kit',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Gear Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Estimated Weight (Kilograms)',
                    hintText: 'e.g. 0.75',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Enter estimated weight';
                    }
                    if (double.tryParse(val.trim()) == null) {
                      return 'Must be a valid decimal number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mission-Critical Essential Gear'),
                  subtitle: const Text(
                    'Prioritized during auto-pack optimization & emergency readiness checks.',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: _isEssential,
                  activeColor: colorScheme.primary,
                  onChanged: (val) => setState(() => _isEssential = val),
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
                    'Add Item to Checklist',
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

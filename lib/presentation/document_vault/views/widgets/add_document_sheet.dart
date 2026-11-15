import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/document_vault_controller.dart';

class AddDocumentSheet extends StatefulWidget {
  final String tripId;

  const AddDocumentSheet({super.key, required this.tripId});

  @override
  State<AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends State<AddDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(
    text: 'Alpine Mountain Transit Pass',
  );
  final _carrierController = TextEditingController(text: 'VoyageAir Shuttle');
  final _flightNumController = TextEditingController(text: 'VA-204');
  final _originController = TextEditingController(text: 'LHE');
  final _destController = TextEditingController(text: 'KDU');
  final _gateController = TextEditingController(text: 'C2');
  final _seatController = TextEditingController(text: '08F');
  final _timeController = TextEditingController(text: '08:15 AM');
  final _pnrController = TextEditingController(text: 'VY-48192');
  final _notesController = TextEditingController(
    text: 'Priority mountain boarding pass.',
  );

  String _selectedType = 'Flight';
  static const List<String> _types = ['Flight', 'Hotel', 'Rail', 'Passport'];

  @override
  void dispose() {
    _titleController.dispose();
    _carrierController.dispose();
    _flightNumController.dispose();
    _originController.dispose();
    _destController.dispose();
    _gateController.dispose();
    _seatController.dispose();
    _timeController.dispose();
    _pnrController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final ctrl = Get.find<DocumentVaultController>();
      ctrl.addDocument(
        tripId: widget.tripId,
        type: _selectedType,
        title: _titleController.text.trim(),
        originIata: _originController.text.trim(),
        destinationIata: _destController.text.trim(),
        flightOrBookingNumber: _flightNumController.text.trim(),
        gate: _gateController.text.trim(),
        seat: _seatController.text.trim(),
        boardingTime: _timeController.text.trim(),
        pnrCode: _pnrController.text.trim(),
        carrierName: _carrierController.text.trim(),
        notes: _notesController.text.trim(),
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
                  'Add Travel Document / Pass',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Document Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _types.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Pass Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carrierController,
                        decoration: const InputDecoration(
                          labelText: 'Carrier Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _flightNumController,
                        decoration: const InputDecoration(
                          labelText: 'Number / Code',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _originController,
                        decoration: const InputDecoration(
                          labelText: 'Origin IATA',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _destController,
                        decoration: const InputDecoration(
                          labelText: 'Destination IATA',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gateController,
                        decoration: const InputDecoration(
                          labelText: 'Gate',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _seatController,
                        decoration: const InputDecoration(
                          labelText: 'Seat',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _pnrController,
                        decoration: const InputDecoration(
                          labelText: 'PNR Code',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Boarding / Check-in Time',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Field Notes',
                    border: OutlineInputBorder(),
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
                    'Vault Document',
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

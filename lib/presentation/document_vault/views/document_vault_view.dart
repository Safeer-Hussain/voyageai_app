import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/document_vault_controller.dart';
import 'widgets/add_document_sheet.dart';
import 'widgets/barcode_painter.dart';
import 'widgets/boarding_pass_card.dart';

class DocumentVaultView extends StatelessWidget {
  const DocumentVaultView({super.key});

  void _showAddDocument(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddDocumentSheet(tripId: tripId),
    );
  }

  void _showPassInspection(BuildContext context, dynamic doc) {
    final colorScheme = Theme.of(context).colorScheme;
    final ctrl = Get.find<DocumentVaultController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Obx(() {
          final isBoosted = ctrl.isBrightnessBoosted.value;
          return Container(
            color: isBoosted ? Colors.white : colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isBoosted
                              ? Colors.grey.shade400
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'BOARDING PASS INSPECTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: isBoosted
                                ? Colors.black87
                                : colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            isBoosted
                                ? Icons.brightness_high
                                : Icons.brightness_6,
                            color: isBoosted
                                ? Colors.amber.shade800
                                : colorScheme.secondary,
                          ),
                          tooltip: 'Toggle Brightness Boost',
                          onPressed: ctrl.toggleBrightnessBoost,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isBoosted ? Colors.black : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doc.originIata} -> ${doc.destinationIata}  •  ${doc.flightOrBookingNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isBoosted
                            ? Colors.grey.shade800
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: BarcodePainter(
                                payload: doc.qrPayload,
                                barColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doc.pnrCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInspectionField(
                          'GATE',
                          doc.gate,
                          isBoosted,
                          colorScheme,
                        ),
                        _buildInspectionField(
                          'SEAT',
                          doc.seat,
                          isBoosted,
                          colorScheme,
                        ),
                        _buildInspectionField(
                          'TIME',
                          doc.boardingTime,
                          isBoosted,
                          colorScheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        ctrl.copyPnr(doc.pnrCode);
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text('Copy PNR Reference (${doc.pnrCode})'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        backgroundColor: isBoosted
                            ? Colors.blueGrey.shade900
                            : colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  static Widget _buildInspectionField(
    String label,
    String value,
    bool isBoosted,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isBoosted
                ? Colors.grey.shade700
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isBoosted ? Colors.black : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DocumentVaultController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;

    // Load active trip docs
    if (itineraryCtrl.activeTrip.value != null && ctrl.documents.isEmpty) {
      ctrl.loadDocuments(itineraryCtrl.activeTrip.value!.id);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_vault_add_pass',
        onPressed: () {
          final tripId = itineraryCtrl.activeTrip.value?.id ?? 'trip_hunza_7d';
          _showAddDocument(context, tripId);
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add Document',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final docs = ctrl.filteredDocuments;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAVEL DOCUMENT & BOARDING PASS VAULT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'High-contrast offline passes with vector barcodes & brightness boost.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              // Category Filter Bar
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: DocumentVaultController.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final cat = DocumentVaultController.categories[index];
                    final isSelected = ctrl.selectedCategory.value == cat;
                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: colorScheme.primaryContainer,
                      backgroundColor: colorScheme.surfaceContainer,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      onSelected: (_) => ctrl.selectCategory(cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.badge, size: 42, color: colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'No documents found in this category.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...docs.map((doc) {
                  return BoardingPassCard(
                    document: doc,
                    onTap: () => _showPassInspection(context, doc),
                    onCopyPnr: () => ctrl.copyPnr(doc.pnrCode),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}

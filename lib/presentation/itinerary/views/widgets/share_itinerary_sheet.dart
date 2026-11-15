import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/itinerary_controller.dart';

class ShareItinerarySheet extends StatelessWidget {
  const ShareItinerarySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Share & Export Expedition Dossier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Distribute formatted itinerary outlines or raw JSON structure.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              leading: Icon(Icons.copy, color: colorScheme.primary),
              title: const Text(
                'Copy Formatted Day-by-Day Plan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: const Text(
                'Plain-text breakdown suitable for field briefings and group messages.',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await ctrl.copyPlanToClipboard();
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              leading: Icon(Icons.data_object, color: colorScheme.secondary),
              title: const Text(
                'Export JSON Travel Dossier',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: const Text(
                'Full machine-readable expedition data with waypoints and metadata.',
                style: TextStyle(fontSize: 11),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await ctrl.exportJsonDossier();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

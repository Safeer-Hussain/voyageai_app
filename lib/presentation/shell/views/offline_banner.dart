import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavigationController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (!navCtrl.isOffline.value || navCtrl.isRoamingBannerDismissed.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: colorScheme.secondaryContainer,
        child: Row(
          children: [
            Icon(
              Icons.airplanemode_active,
              size: 18,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Airplane / Offline Roaming Mode - Serving Local SQLite Boarding Passes, Maps & Itineraries',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            InkWell(
              onTap: navCtrl.dismissRoamingBanner,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

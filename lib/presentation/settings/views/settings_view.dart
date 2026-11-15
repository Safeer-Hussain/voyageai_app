import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../di/service_locator.dart';
import '../../expense_ledger/controllers/expense_ledger_controller.dart';
import '../../itinerary/controllers/itinerary_controller.dart';
import 'recruiter_debug_drawer.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = sl<ThemeController>();
    final expenseCtrl = Get.find<ExpenseLedgerController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      endDrawer: const RecruiterDebugDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APPEARANCE & THEME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      themeCtrl.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            themeCtrl.isDarkMode
                                ? 'Midnight Horizon Dark'
                                : 'Crisp Passport Light',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            themeCtrl.isDarkMode
                                ? 'Optimized for nighttime navigation & AMOLED power efficiency.'
                                : 'High contrast clean daylight readability.',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: themeCtrl.isDarkMode,
                      activeColor: colorScheme.primary,
                      onChanged: (_) => themeCtrl.toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'PRIMARY ACCOUNTING CURRENCY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: AppConstants.supportedCurrencies.map((code) {
                    return Obx(() {
                      final isSelected =
                          expenseCtrl.selectedCurrency.value == code;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          code,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        onTap: () {
                          expenseCtrl.setCurrency(code);
                          AppFeedback.showInfo(
                            title: 'Currency Updated',
                            message:
                                'All ledgers and charts now display in $code.',
                          );
                        },
                      );
                    });
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'OFFLINE VAULT STORAGE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.storage, color: colorScheme.secondary),
                    title: const Text('Local SQLite Database'),
                    subtitle: Obx(
                      () => Text(
                        '${itineraryCtrl.trips.length} expeditions, ${itineraryCtrl.activities.length} activities persisted.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.refresh, color: colorScheme.error),
                    title: const Text('Re-Seed Vault to Defaults'),
                    subtitle: Text(
                      'Restores the 3 flagship expeditions and sample boarding passes.',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () async {
                      await sl<AppDatabase>().clearAll();
                      await sl<AppDatabase>().seedInitialDataIfEmpty();
                      await itineraryCtrl.loadInitialData();
                      AppFeedback.showSuccess(
                        title: 'Vault Re-Seeded',
                        message: 'Default itineraries and passes restored.',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Builder(
                builder: (scaffoldContext) {
                  return GestureDetector(
                    onLongPress: () {
                      Scaffold.of(scaffoldContext).openEndDrawer();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'VoyageAI ${AppConstants.appVersion}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Long-press to open Recruiter Debug Drawer',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/itinerary_controller.dart';
import '../../currency/views/currency_cheat_sheet_view.dart';
import '../../jetlag/views/jetlag_planner_view.dart';
import '../../packing/views/packing_checklist_view.dart';
import 'widgets/activity_card.dart';
import 'widgets/add_activity_sheet.dart';
import 'widgets/generate_trip_sheet.dart';
import 'widgets/share_itinerary_sheet.dart';

class ItineraryView extends StatelessWidget {
  const ItineraryView({super.key});

  void _showAddActivity(BuildContext context, int defaultDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddActivitySheet(defaultDay: defaultDay),
    );
  }

  void _showGenerateTrip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const GenerateTripSheet(),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ShareItinerarySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_itinerary_add_activity',
        onPressed: () => _showAddActivity(context, ctrl.selectedDay.value),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add Activity',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.activeTrip.value == null) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final trip = ctrl.activeTrip.value;
        if (trip == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_off, size: 48, color: colorScheme.outline),
                const SizedBox(height: 12),
                Text(
                  'No Expeditions Found',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _showGenerateTrip(context),
                  child: const Text('Generate New AI Trip'),
                ),
              ],
            ),
          );
        }

        if (isLandscape) {
          return Row(
            children: [
              // Left Pane: Trip Info, Switcher, and Day Chips
              SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTripHeader(context, ctrl, colorScheme),
                      const SizedBox(height: 12),
                      _buildProgressBar(ctrl, colorScheme),
                      const SizedBox(height: 12),
                      _buildDaySelector(ctrl, colorScheme, trip.durationDays),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              // Right Pane: Filter Chips and Timeline List
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryFilters(ctrl, colorScheme),
                      const SizedBox(height: 12),
                      _buildTimelineList(ctrl, colorScheme),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTripHeader(context, ctrl, colorScheme),
              const SizedBox(height: 12),
              _buildProgressBar(ctrl, colorScheme),
              const SizedBox(height: 16),
              _buildDaySelector(ctrl, colorScheme, trip.durationDays),
              const SizedBox(height: 14),
              _buildCategoryFilters(ctrl, colorScheme),
              const SizedBox(height: 14),
              _buildTimelineList(ctrl, colorScheme),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTripHeader(
    BuildContext context,
    ItineraryController ctrl,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: ctrl.activeTrip.value?.id,
                      dropdownColor: colorScheme.surfaceContainerHighest,
                      items: ctrl.trips.map((t) {
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(
                            t.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (id) {
                        if (id != null) ctrl.switchTrip(id);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.currency_exchange,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Currency & Tip Cheat-Sheet',
                  onPressed: () => Get.to(() => const CurrencyCheatSheetView()),
                ),
                IconButton(
                  icon: Icon(
                    Icons.timelapse_outlined,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Circadian Jetlag Protocol',
                  onPressed: () => Get.to(() => const JetlagPlannerView()),
                ),
                IconButton(
                  icon: Icon(
                    Icons.luggage_outlined,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Packing Checklist',
                  onPressed: () => Get.to(() => const PackingChecklistView()),
                ),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: colorScheme.primary),
                  tooltip: 'Share Dossier',
                  onPressed: () => _showShareSheet(context),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Generate Trip',
                  onPressed: () => _showGenerateTrip(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ctrl.activeTrip.value?.destination ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: colorScheme.secondary.withAlpha(35),
                  ),
                  child: Text(
                    ctrl.activeTrip.value?.budgetTier.toUpperCase() ?? '',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ItineraryController ctrl, ColorScheme colorScheme) {
    final progress = ctrl.tripCompletionPercentage;
    final completedCount = ctrl.activities.where((a) => a.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXPEDITION PROGRESS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$completedCount/${ctrl.activities.length} (${(progress * 100).toStringAsFixed(0)}%)',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(
    ItineraryController ctrl,
    ColorScheme colorScheme,
    int durationDays,
  ) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: durationDays,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = ctrl.selectedDay.value == day;

          return ChoiceChip(
            label: Text('Day $day'),
            selected: isSelected,
            selectedColor: colorScheme.primaryContainer,
            backgroundColor: colorScheme.surfaceContainer,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
            onSelected: (_) => ctrl.selectDay(day),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(
    ItineraryController ctrl,
    ColorScheme colorScheme,
  ) {
    const categories = [
      'All',
      'Flight',
      'Hotel',
      'Landmark',
      'Dining',
      'Transit',
    ];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected =
              ctrl.filterCategory.value.toLowerCase() == cat.toLowerCase();

          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: colorScheme.secondary.withAlpha(40),
            backgroundColor: colorScheme.surfaceContainerLow,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.secondary
                    : colorScheme.outlineVariant,
              ),
            ),
            onSelected: (_) => ctrl.setFilterCategory(cat),
          );
        },
      ),
    );
  }

  Widget _buildTimelineList(ItineraryController ctrl, ColorScheme colorScheme) {
    final acts = ctrl.currentDayActivities;
    if (acts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.calendar_today, size: 36, color: colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No activities scheduled for Day ${ctrl.selectedDay.value}.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: acts.map((activity) {
        return ActivityCard(
          activity: activity,
          onToggleCompleted: () => ctrl.toggleActivityCompleted(activity.id),
        );
      }).toList(),
    );
  }
}

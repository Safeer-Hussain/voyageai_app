import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/jetlag_controller.dart';
import 'widgets/circadian_clock_cockpit.dart';
import 'widgets/custom_jetlag_planner_sheet.dart';
import 'widgets/shift_day_card.dart';

class JetlagPlannerView extends StatelessWidget {
  const JetlagPlannerView({super.key});

  void _showCustomPlanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CustomJetlagPlannerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<JetlagController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Circadian Jetlag & Sleep Protocol',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Checkpoints',
            onPressed: ctrl.resetPlan,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_jetlag_custom_plan',
        onPressed: () => _showCustomPlanSheet(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.tune, size: 20),
        label: const Text(
          'Custom Plan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        final currentTrip = itineraryCtrl.activeTrip.value;
        if (currentTrip != null && ctrl.activeTripId.value != currentTrip.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ctrl.loadPlan(currentTrip.id);
          });
        }

        if (ctrl.isLoading.value && ctrl.activePlan.value == null) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final plan = ctrl.activePlan.value;
        if (plan == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bedtime_off_outlined,
                  size: 40,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Circadian Shift Plan Found',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _showCustomPlanSheet(context),
                  child: const Text('Generate Shift Plan'),
                ),
              ],
            ),
          );
        }

        final cockpitWidget = CircadianClockCockpit(ctrl: ctrl);
        final listWidget = _buildTimelineList(plan, ctrl, colorScheme);

        if (isLandscape) {
          return Row(
            children: [
              SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(children: [cockpitWidget]),
                ),
              ),
              const VerticalDivider(width: 1),
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
                      _buildTimelineHeader(colorScheme),
                      const SizedBox(height: 8),
                      listWidget,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cockpitWidget,
              const SizedBox(height: 14),
              _buildTimelineHeader(colorScheme),
              const SizedBox(height: 8),
              listWidget,
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimelineHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'CIRCADIAN SHIFT TIMELINE & PROTOCOLS',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(
    dynamic plan,
    JetlagController ctrl,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: plan.shiftDays.map<Widget>((day) {
        return ShiftDayCard(day: day, ctrl: ctrl);
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/flight_claim_controller.dart';
import 'widgets/claim_history_card.dart';
import 'widgets/eligibility_cockpit.dart';
import 'widgets/flight_input_form.dart';

class FlightDelayEvaluatorView extends StatelessWidget {
  const FlightDelayEvaluatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FlightClaimController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final tripId = itineraryCtrl.activeTrip.value?.id ?? 'trip_hunza_7d';

    // Ensure claims are loaded for active trip
    controller.loadClaims(tripId);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isLandscape ? 36 : 48,
        title: Text(
          'EU261 / ICAO FLIGHT DELAY EVALUATOR',
          style: TextStyle(
            fontSize: isLandscape ? 12 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined, size: 20),
            tooltip: 'Save Claim to Dossier',
            onPressed: () => controller.saveCurrentClaim(tripId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_flight_claim_evaluate',
        onPressed: () => controller.evaluate(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.calculate_outlined, size: 20),
        label: const Text(
          'Re-Evaluate',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: Flight Input Form
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FlightInputForm(controller: controller),
                          const SizedBox(height: 72),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Right Pane: Eligibility Cockpit & History
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EligibilityCockpit(controller: controller),
                          const SizedBox(height: 12),
                          ClaimHistoryCard(
                            controller: controller,
                            tripId: tripId,
                          ),
                          const SizedBox(height: 72),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlightInputForm(controller: controller),
                    const SizedBox(height: 14),
                    EligibilityCockpit(controller: controller),
                    const SizedBox(height: 14),
                    ClaimHistoryCard(controller: controller, tripId: tripId),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }
}

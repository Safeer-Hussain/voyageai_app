import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/flight_claim.dart';
import '../../controllers/flight_claim_controller.dart';

class FlightInputForm extends StatelessWidget {
  final FlightClaimController controller;

  const FlightInputForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final disruption = controller.disruptionType.value;
      final delayMins = controller.delayMinutes.value;
      final noticeDays = controller.cancellationNoticeDays.value;
      final isExtraordinary = controller.isExtraordinary.value;

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flight_takeoff,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FLIGHT DISRUPTION PARAMETERS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Preset Scenarios
            Text(
              'Quick Sample Scenarios',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: [
                  _buildScenarioChip(
                    label: 'Short-Haul (BA LHR-FRA)',
                    index: 0,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 6),
                  _buildScenarioChip(
                    label: 'Long-Haul (AF CDG-JFK)',
                    index: 1,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 6),
                  _buildScenarioChip(
                    label: 'Cancelled (KL AMS-ATH)',
                    index: 2,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 6),
                  _buildScenarioChip(
                    label: 'Non-EU (EK DXB-JFK)',
                    index: 3,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 6),
                  _buildScenarioChip(
                    label: 'Blizzard (Extraordinary)',
                    index: 4,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Flight Number & Carrier
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: controller.flightNumber.value,
                    decoration: InputDecoration(
                      labelText: 'Flight Number',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) => controller.flightNumber.value = val,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    initialValue: controller.carrierName.value,
                    decoration: InputDecoration(
                      labelText: 'Airline Carrier',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(Icons.airlines, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) => controller.carrierName.value = val,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Origin & Destination IATA
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: controller.originIata.value,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 3,
                    decoration: InputDecoration(
                      labelText: 'Origin IATA',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: 'e.g. LHR',
                      counterText: '',
                      prefixIcon: const Icon(Icons.flight_takeoff, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) {
                      if (val.length == 3) controller.setOrigin(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    final orig = controller.originIata.value;
                    controller.setOrigin(controller.destinationIata.value);
                    controller.setDestination(orig);
                  },
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  tooltip: 'Swap Route',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: controller.destinationIata.value,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 3,
                    decoration: InputDecoration(
                      labelText: 'Destination IATA',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: 'e.g. JFK',
                      counterText: '',
                      prefixIcon: const Icon(Icons.flight_land, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) {
                      if (val.length == 3) controller.setDestination(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Disruption Type Selector
            Text(
              'Disruption Type',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTypeChip(
                  label: 'Delay at Arrival',
                  type: DisruptionType.delay,
                  colorScheme: colorScheme,
                ),
                _buildTypeChip(
                  label: 'Flight Cancellation',
                  type: DisruptionType.cancellation,
                  colorScheme: colorScheme,
                ),
                _buildTypeChip(
                  label: 'Denied Boarding',
                  type: DisruptionType.deniedBoarding,
                  colorScheme: colorScheme,
                ),
                _buildTypeChip(
                  label: 'Missed Connection',
                  type: DisruptionType.missedConnection,
                  colorScheme: colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Dynamic Sub-parameters based on disruption type
            if (disruption == DisruptionType.delay ||
                disruption == DisruptionType.missedConnection) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Arrival Delay Duration',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: delayMins >= 180
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${delayMins ~/ 60}h ${delayMins % 60}m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: delayMins >= 180
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: delayMins.toDouble().clamp(30.0, 720.0),
                min: 30.0,
                max: 720.0,
                divisions: 23, // 30-min increments
                activeColor: colorScheme.primary,
                label: '${delayMins ~/ 60}h ${delayMins % 60}m',
                onChanged: (val) => controller.setDelayMinutes(val.toInt()),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  children: [
                    _buildQuickDelayButton('2h', 120, colorScheme),
                    const SizedBox(width: 6),
                    _buildQuickDelayButton('3h Threshold', 185, colorScheme),
                    const SizedBox(width: 6),
                    _buildQuickDelayButton('4h Long-Haul', 245, colorScheme),
                    const SizedBox(width: 6),
                    _buildQuickDelayButton('6h+', 360, colorScheme),
                  ],
                ),
              ),
            ] else if (disruption == DisruptionType.cancellation) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Notice Prior to Departure',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$noticeDays Days Notice',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: noticeDays.toDouble().clamp(0.0, 21.0),
                min: 0.0,
                max: 21.0,
                divisions: 21,
                activeColor: colorScheme.primary,
                label: '$noticeDays Days',
                onChanged: (val) =>
                    controller.setCancellationNoticeDays(val.toInt()),
              ),
              Text(
                'Note: Notice of >14 days exempts statutory cash compensation (refund or rerouting only).',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Operating Carrier EU & Extraordinary Circumstances Checkboxes
            Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: controller.isCarrierEu.value,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: colorScheme.primary,
                      title: const Text(
                        'Operating Carrier is EU / EEA / UK Licensed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Mandatory for incoming flights arriving from non-EU origins.',
                        style: TextStyle(fontSize: 10),
                      ),
                      onChanged: (val) => controller.setCarrierEu(val ?? false),
                    ),
                    const Divider(height: 8),
                    CheckboxListTile(
                      value: isExtraordinary,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.deepOrange,
                      title: const Text(
                        'Certified Extraordinary Circumstances',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                      subtitle: const Text(
                        'Severe weather closure, ATC strike, security risks (Technical faults are NOT extraordinary).',
                        style: TextStyle(fontSize: 10),
                      ),
                      onChanged: (val) =>
                          controller.setExtraordinary(val ?? false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildScenarioChip({
    required String label,
    required int index,
    required ColorScheme colorScheme,
  }) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      onPressed: () => controller.loadPresetScenario(index),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required DisruptionType type,
    required ColorScheme colorScheme,
  }) {
    final isSelected = controller.disruptionType.value == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      onSelected: (_) => controller.setDisruptionType(type),
    );
  }

  Widget _buildQuickDelayButton(
    String label,
    int minutes,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () => controller.setDelayMinutes(minutes),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

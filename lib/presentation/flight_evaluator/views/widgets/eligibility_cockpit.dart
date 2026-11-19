import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/flight_claim.dart';
import '../../controllers/flight_claim_controller.dart';
import 'statutory_claim_letter_sheet.dart';

class EligibilityCockpit extends StatelessWidget {
  final FlightClaimController controller;

  const EligibilityCockpit({super.key, required this.controller});

  void _showClaimLetter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatutoryClaimLetterSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final elig = controller.eligibility.value;
      if (elig == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final isEligible = elig.isEligible;
      final isUk = elig.primaryRegulation == Jurisdiction.uk261;
      final currencySymbol = isUk ? '£' : '€';
      final compensationAmount = isUk ? elig.amountGbp : elig.amountEur;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Result Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEligible
                    ? [colorScheme.primary, colorScheme.primary.withAlpha(210)]
                    : [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainer,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isEligible
                      ? colorScheme.primary.withAlpha(50)
                      : Colors.transparent,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isEligible
                              ? Colors.black.withAlpha(50)
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEligible
                              ? 'COMPENSATION APPROVED'
                              : 'INELIGIBLE FOR CASH PAYOUT',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isEligible
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      elig.primaryRegulation == Jurisdiction.uk261
                          ? 'UK261'
                          : elig.primaryRegulation == Jurisdiction.eu261
                          ? 'EU261 / EC 261'
                          : 'MONTREAL CONVENTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isEligible
                            ? Colors.white.withAlpha(220)
                            : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isEligible
                          ? '$currencySymbol${compensationAmount.toStringAsFixed(0)}'
                          : '€0',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: isEligible
                            ? Colors.white
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEligible
                            ? 'per passenger (~ \$${elig.amountUsdEquivalent.toStringAsFixed(0)} USD)'
                            : 'No statutory cash payout',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isEligible
                              ? Colors.white.withAlpha(210)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  elig.eligibilityReason,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: isEligible
                        ? Colors.white.withAlpha(230)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Route & Distance Matrix Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCol(
                    title: 'ROUTE',
                    value:
                        '${controller.originIata.value} -> ${controller.destinationIata.value}',
                    colorScheme: colorScheme,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildMetricCol(
                    title: 'DISTANCE',
                    value: '${elig.distanceKm.toStringAsFixed(0)} km',
                    colorScheme: colorScheme,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildMetricCol(
                    title: 'TIER',
                    value: elig.distanceTier == DistanceTier.shortHaul
                        ? '< 1500 km'
                        : elig.distanceTier == DistanceTier.mediumHaul
                        ? '1500-3500 km'
                        : '> 3500 km',
                    colorScheme: colorScheme,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildMetricCol(
                    title: 'DEFENSE RISK',
                    value: controller.isExtraordinary.value ? 'HIGH' : 'LOW',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Duty of Care Advisory
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.room_service_outlined,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'STATUTORY RIGHT TO CARE (ARTICLE 9)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  elig.dutyOfCareSummary,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Applicable Articles & Precedents
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEGAL BASES & CJEU CASE LAW',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                for (final art in elig.applicableArticles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.gavel, size: 13, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            art,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Claim Letter CTA
          FilledButton.icon(
            onPressed: () => _showClaimLetter(context),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text(
              'View Statutory Claim Notice Letter',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricCol({
    required String title,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

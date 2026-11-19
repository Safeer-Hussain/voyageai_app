import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/flight_claim.dart';
import '../../controllers/flight_claim_controller.dart';

class ClaimHistoryCard extends StatelessWidget {
  final FlightClaimController controller;
  final String tripId;

  const ClaimHistoryCard({
    super.key,
    required this.controller,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final claims = controller.filteredClaims;

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
                Icon(Icons.history_edu, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'SAVED CLAIMS (${claims.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => controller.saveCurrentClaim(tripId),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 14),
                  label: const Text('Save', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (claims.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.airplane_ticket_outlined,
                        size: 32,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No compensation claims saved for this expedition.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: claims.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final claim = claims[index];
                  return _buildClaimItem(claim, colorScheme);
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildClaimItem(FlightClaim claim, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    claim.flightNumber,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '(${claim.originIata} -> ${claim.destinationIata})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(claim.status, colorScheme),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              claim.carrierName,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              claim.isEligible
                  ? (claim.primaryJurisdiction == Jurisdiction.uk261
                        ? '£${claim.compensationGbp.toStringAsFixed(0)}'
                        : '€${claim.compensationEur.toStringAsFixed(0)}')
                  : 'Ineligible',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: claim.isEligible
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PNR: ${claim.bookingReference}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              children: [
                PopupMenuButton<ClaimStatus>(
                  tooltip: 'Update Status',
                  icon: Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  onSelected: (newStatus) {
                    controller.updateClaimStatus(claim.id, newStatus, tripId);
                  },
                  itemBuilder: (context) => [
                    for (final status in ClaimStatus.values)
                      PopupMenuItem(
                        value: status,
                        child: Text(
                          status.name.toUpperCase(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Delete Claim',
                  onPressed: () => controller.deleteClaim(claim.id, tripId),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ClaimStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case ClaimStatus.draft:
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
        break;
      case ClaimStatus.submitted:
        bg = Colors.blue.withAlpha(40);
        fg = Colors.blue.shade700;
        break;
      case ClaimStatus.underReview:
        bg = Colors.amber.withAlpha(40);
        fg = Colors.amber.shade800;
        break;
      case ClaimStatus.settled:
        bg = Colors.green.withAlpha(40);
        fg = Colors.green.shade700;
        break;
      case ClaimStatus.rejected:
        bg = colorScheme.error.withAlpha(40);
        fg = colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

import '../entities/flight_claim.dart';

abstract class FlightClaimRepository {
  Future<List<FlightClaim>> getClaimsForTrip(String tripId);

  Future<FlightClaim?> getClaimById(String id);

  Future<void> saveClaim(FlightClaim claim);

  Future<void> updateClaimStatus(String claimId, ClaimStatus status);

  Future<void> deleteClaim(String claimId);

  CompensationEligibility evaluateEligibility({
    required String originIata,
    required String destinationIata,
    required bool isCarrierEu,
    required DisruptionType disruptionType,
    required int delayMinutes,
    int? cancellationNoticeDays,
    required bool isExtraordinary,
    String? flightNumber,
    String? carrierName,
    String? passengerName,
    String? bookingReference,
    String? flightDate,
  });

  String generateClaimLetter({
    required String flightNumber,
    required String carrierName,
    required String originIata,
    required String destinationIata,
    required String flightDate,
    required String passengerName,
    required String bookingReference,
    required DisruptionType disruptionType,
    required int delayMinutes,
    required CompensationEligibility eligibility,
  });
}

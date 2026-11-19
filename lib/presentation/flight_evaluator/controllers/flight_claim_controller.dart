import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/document.dart';
import '../../../domain/entities/flight_claim.dart';
import '../../../domain/repositories/flight_claim_repository.dart';

class FlightClaimController extends GetxController {
  final FlightClaimRepository _repository;

  FlightClaimController(this._repository);

  // Form Fields
  final flightNumber = 'LH 430'.obs;
  final carrierName = 'Lufthansa'.obs;
  final originIata = 'FRA'.obs;
  final destinationIata = 'ORD'.obs;
  final isCarrierEu = true.obs;
  final flightDate = DateTime.now().obs;
  final disruptionType = DisruptionType.delay.obs;
  final delayMinutes = 245.obs; // 4h 05m
  final cancellationNoticeDays = 5.obs;
  final isExtraordinary = false.obs;
  final passengerName = 'Safeer Hussain'.obs;
  final bookingReference = 'VY-LH8921'.obs;

  // Evaluation & History
  final eligibility = Rx<CompensationEligibility?>(null);
  final savedClaims = <FlightClaim>[].obs;
  final isLoading = false.obs;
  final selectedStatusFilter = Rx<ClaimStatus?>(null);

  @override
  void onInit() {
    super.onInit();
    evaluate();
  }

  void evaluate() {
    eligibility.value = _repository.evaluateEligibility(
      originIata: originIata.value,
      destinationIata: destinationIata.value,
      isCarrierEu: isCarrierEu.value,
      disruptionType: disruptionType.value,
      delayMinutes: delayMinutes.value,
      cancellationNoticeDays: cancellationNoticeDays.value,
      isExtraordinary: isExtraordinary.value,
      flightNumber: flightNumber.value,
      carrierName: carrierName.value,
      passengerName: passengerName.value,
      bookingReference: bookingReference.value,
      flightDate: flightDate.value.toIso8601String().substring(0, 10),
    );
  }

  void setDisruptionType(DisruptionType type) {
    disruptionType.value = type;
    evaluate();
  }

  void setDelayMinutes(int minutes) {
    delayMinutes.value = minutes;
    evaluate();
  }

  void setCancellationNoticeDays(int days) {
    cancellationNoticeDays.value = days;
    evaluate();
  }

  void setExtraordinary(bool val) {
    isExtraordinary.value = val;
    evaluate();
  }

  void setCarrierEu(bool val) {
    isCarrierEu.value = val;
    evaluate();
  }

  void setOrigin(String iata) {
    originIata.value = iata.trim().toUpperCase();
    final airport = AirportCatalog.findByIata(originIata.value);
    if (airport != null && airport.isEu) {
      isCarrierEu.value = true;
    }
    evaluate();
  }

  void setDestination(String iata) {
    destinationIata.value = iata.trim().toUpperCase();
    evaluate();
  }

  void loadPresetScenario(int scenarioIndex) {
    switch (scenarioIndex) {
      case 0:
        // Short-haul delay (LHR -> FRA, BA)
        flightNumber.value = 'BA 902';
        carrierName.value = 'British Airways';
        originIata.value = 'LHR';
        destinationIata.value = 'FRA';
        isCarrierEu.value = true;
        disruptionType.value = DisruptionType.delay;
        delayMinutes.value = 210; // 3h 30m
        isExtraordinary.value = false;
        bookingReference.value = 'BA-UK4891';
        break;
      case 1:
        // Long-haul delay (CDG -> JFK, Air France)
        flightNumber.value = 'AF 006';
        carrierName.value = 'Air France';
        originIata.value = 'CDG';
        destinationIata.value = 'JFK';
        isCarrierEu.value = true;
        disruptionType.value = DisruptionType.delay;
        delayMinutes.value = 280; // 4h 40m
        isExtraordinary.value = false;
        bookingReference.value = 'AF-FR7712';
        break;
      case 2:
        // Medium-haul cancellation (AMS -> ATH, KLM)
        flightNumber.value = 'KL 1575';
        carrierName.value = 'KLM Royal Dutch Airlines';
        originIata.value = 'AMS';
        destinationIata.value = 'ATH';
        isCarrierEu.value = true;
        disruptionType.value = DisruptionType.cancellation;
        cancellationNoticeDays.value = 3;
        isExtraordinary.value = false;
        bookingReference.value = 'KL-NL3390';
        break;
      case 3:
        // Non-EU route outside EU261 (DXB -> JFK, Emirates)
        flightNumber.value = 'EK 201';
        carrierName.value = 'Emirates';
        originIata.value = 'DXB';
        destinationIata.value = 'JFK';
        isCarrierEu.value = false;
        disruptionType.value = DisruptionType.delay;
        delayMinutes.value = 300;
        isExtraordinary.value = false;
        bookingReference.value = 'EK-DXB101';
        break;
      case 4:
        // Extraordinary circumstance (Blizzard closure)
        flightNumber.value = 'LH 1800';
        carrierName.value = 'Lufthansa';
        originIata.value = 'MUC';
        destinationIata.value = 'MAD';
        isCarrierEu.value = true;
        disruptionType.value = DisruptionType.delay;
        delayMinutes.value = 360;
        isExtraordinary.value = true;
        bookingReference.value = 'LH-MU5521';
        break;
    }
    evaluate();
    AppFeedback.showInfo(
      title: 'Scenario Loaded',
      message: 'Loaded sample scenario: ${flightNumber.value}',
    );
  }

  void populateFromDocument(TravelDocument doc) {
    if (doc.type.toLowerCase() == 'flight') {
      flightNumber.value = doc.flightOrBookingNumber.isNotEmpty
          ? doc.flightOrBookingNumber
          : flightNumber.value;
      carrierName.value = doc.carrierName.isNotEmpty
          ? doc.carrierName
          : carrierName.value;
      if (doc.originIata.isNotEmpty) originIata.value = doc.originIata;
      if (doc.destinationIata.isNotEmpty) {
        destinationIata.value = doc.destinationIata;
      }
      if (doc.pnrCode.isNotEmpty) bookingReference.value = doc.pnrCode;
      evaluate();
      AppFeedback.showSuccess(
        title: 'Document Linked',
        message:
            'Imported flight details from pass: ${doc.flightOrBookingNumber}',
      );
    } else {
      AppFeedback.showWarning(
        title: 'Invalid Document',
        message: 'Selected document is not a flight pass.',
      );
    }
  }

  Future<void> loadClaims(String tripId) async {
    isLoading.value = true;
    try {
      final list = await _repository.getClaimsForTrip(tripId);
      savedClaims.assignAll(list);
    } catch (_) {
      // defensive catch
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCurrentClaim(String tripId) async {
    evaluate();
    final currentElig = eligibility.value;
    if (currentElig == null) return;

    final newClaim = FlightClaim(
      id: 'claim_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      flightNumber: flightNumber.value.trim(),
      carrierName: carrierName.value.trim(),
      originIata: originIata.value.trim().toUpperCase(),
      destinationIata: destinationIata.value.trim().toUpperCase(),
      isCarrierEu: isCarrierEu.value,
      flightDate: flightDate.value.toIso8601String().substring(0, 10),
      disruptionType: disruptionType.value,
      delayMinutes: delayMinutes.value,
      cancellationNoticeDays: cancellationNoticeDays.value,
      isExtraordinary: isExtraordinary.value,
      passengerName: passengerName.value.trim(),
      bookingReference: bookingReference.value.trim(),
      isEligible: currentElig.isEligible,
      compensationEur: currentElig.amountEur,
      compensationGbp: currentElig.amountGbp,
      primaryJurisdiction: currentElig.primaryRegulation,
      status: ClaimStatus.draft,
      claimLetter: currentElig.claimLetterTemplate,
      notes: currentElig.eligibilityReason,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.saveClaim(newClaim);
    await loadClaims(tripId);
    AppFeedback.showSuccess(
      title: 'Claim Saved',
      message: 'Flight compensation claim saved to trip dossier.',
    );
  }

  Future<void> updateClaimStatus(
    String claimId,
    ClaimStatus newStatus,
    String tripId,
  ) async {
    await _repository.updateClaimStatus(claimId, newStatus);
    await loadClaims(tripId);
    AppFeedback.showInfo(
      title: 'Status Updated',
      message: 'Claim status updated to ${newStatus.name.toUpperCase()}.',
    );
  }

  Future<void> deleteClaim(String claimId, String tripId) async {
    await _repository.deleteClaim(claimId);
    await loadClaims(tripId);
    AppFeedback.showInfo(
      title: 'Claim Deleted',
      message: 'Flight compensation claim removed.',
    );
  }

  void copyClaimLetterToClipboard() {
    final letter = eligibility.value?.claimLetterTemplate;
    if (letter != null && letter.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: letter));
      AppFeedback.showSuccess(
        title: 'Copied to Clipboard',
        message: 'Formal statutory claim letter copied to clipboard.',
      );
    }
  }

  List<FlightClaim> get filteredClaims {
    if (selectedStatusFilter.value == null) return savedClaims;
    return savedClaims
        .where((c) => c.status == selectedStatusFilter.value)
        .toList();
  }
}

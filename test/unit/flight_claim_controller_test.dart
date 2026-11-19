import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/data/datasources/local_storage_datasource.dart';
import 'package:voyage_ai_app/data/repositories/flight_claim_repository_impl.dart';
import 'package:voyage_ai_app/domain/entities/document.dart';
import 'package:voyage_ai_app/domain/entities/flight_claim.dart';
import 'package:voyage_ai_app/domain/repositories/flight_claim_repository.dart';
import 'package:voyage_ai_app/presentation/flight_evaluator/controllers/flight_claim_controller.dart';

class MockLocalStorageDatasource implements LocalStorageDatasource {
  final List<Map<String, dynamic>> _claims = [];

  @override
  Future<List<Map<String, dynamic>>> getFlightClaimsForTrip(
    String tripId,
  ) async => _claims;

  @override
  Future<Map<String, dynamic>?> getFlightClaimById(String id) async => null;

  @override
  Future<void> insertFlightClaim(Map<String, dynamic> claimMap) async {
    _claims.removeWhere((c) => c['id'] == claimMap['id']);
    _claims.add(claimMap);
  }

  @override
  Future<void> updateFlightClaimStatus(String claimId, String status) async {
    final idx = _claims.indexWhere((c) => c['id'] == claimId);
    if (idx != -1) {
      _claims[idx]['status'] = status;
    }
  }

  @override
  Future<void> deleteFlightClaim(String claimId) async {
    _claims.removeWhere((c) => c['id'] == claimId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFlightClaimRepository implements FlightClaimRepository {
  final List<FlightClaim> _claims = [];

  final FlightClaimRepositoryImpl _evalEngine = FlightClaimRepositoryImpl(
    MockLocalStorageDatasource(),
  );

  @override
  Future<List<FlightClaim>> getClaimsForTrip(String tripId) async {
    return _claims.where((c) => c.tripId == tripId).toList();
  }

  @override
  Future<FlightClaim?> getClaimById(String id) async {
    for (final c in _claims) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> saveClaim(FlightClaim claim) async {
    _claims.removeWhere((c) => c.id == claim.id);
    _claims.add(claim);
  }

  @override
  Future<void> updateClaimStatus(String claimId, ClaimStatus status) async {
    final idx = _claims.indexWhere((c) => c.id == claimId);
    if (idx != -1) {
      _claims[idx] = _claims[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> deleteClaim(String claimId) async {
    _claims.removeWhere((c) => c.id == claimId);
  }

  @override
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
  }) {
    return _evalEngine.evaluateEligibility(
      originIata: originIata,
      destinationIata: destinationIata,
      isCarrierEu: isCarrierEu,
      disruptionType: disruptionType,
      delayMinutes: delayMinutes,
      cancellationNoticeDays: cancellationNoticeDays,
      isExtraordinary: isExtraordinary,
      flightNumber: flightNumber,
      carrierName: carrierName,
      passengerName: passengerName,
      bookingReference: bookingReference,
      flightDate: flightDate,
    );
  }

  @override
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
  }) {
    return _evalEngine.generateClaimLetter(
      flightNumber: flightNumber,
      carrierName: carrierName,
      originIata: originIata,
      destinationIata: destinationIata,
      flightDate: flightDate,
      passengerName: passengerName,
      bookingReference: bookingReference,
      disruptionType: disruptionType,
      delayMinutes: delayMinutes,
      eligibility: eligibility,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlightClaimRepository repository;
  late FlightClaimController controller;

  setUp(() {
    Get.reset();
    repository = MockFlightClaimRepository();
    controller = FlightClaimController(repository);
  });

  tearDown(() {
    Get.reset();
  });

  group('FlightClaimController Unit Tests', () {
    test('Calculates Great-Circle distance accurately between LHR and FRA', () {
      final lhr = AirportCatalog.findByIata('LHR')!;
      final fra = AirportCatalog.findByIata('FRA')!;

      final distance = AirportCatalog.calculateDistanceKm(
        lat1: lhr.latitude,
        lon1: lhr.longitude,
        lat2: fra.latitude,
        lon2: fra.longitude,
      );

      // LHR to FRA distance is approx 650 km
      expect(distance, greaterThan(600));
      expect(distance, lessThan(700));
    });

    test(
      'Evaluates short-haul UK/EU delay over 3 hours as Tier 1 eligible',
      () {
        controller.loadPresetScenario(0); // LHR -> FRA, 210 mins delay
        final elig = controller.eligibility.value!;

        expect(elig.isEligible, isTrue);
        expect(elig.primaryRegulation, Jurisdiction.uk261);
        expect(elig.distanceTier, DistanceTier.shortHaul);
        expect(elig.amountGbp, equals(220.0));
        expect(elig.amountEur, equals(250.0));
      },
    );

    test(
      'Evaluates long-haul EU delay over 4 hours as Tier 3 full compensation',
      () {
        controller.loadPresetScenario(1); // CDG -> JFK, 280 mins delay
        final elig = controller.eligibility.value!;

        expect(elig.isEligible, isTrue);
        expect(elig.primaryRegulation, Jurisdiction.eu261);
        expect(elig.distanceTier, DistanceTier.longHaul);
        expect(elig.amountEur, equals(600.0));
        expect(elig.amountUsdEquivalent, greaterThan(600.0));
      },
    );

    test(
      'Evaluates long-haul EU delay between 3 and 4 hours as 50% rate (€300)',
      () {
        controller.originIata.value = 'CDG';
        controller.destinationIata.value = 'JFK';
        controller.isCarrierEu.value = true;
        controller.setDisruptionType(DisruptionType.delay);
        controller.setDelayMinutes(210); // 3h 30m

        final elig = controller.eligibility.value!;
        expect(elig.isEligible, isTrue);
        expect(elig.distanceTier, DistanceTier.longHaul);
        expect(elig.amountEur, equals(300.0));
      },
    );

    test(
      'Evaluates delay under 3 hours as ineligible for cash compensation',
      () {
        controller.originIata.value = 'FRA';
        controller.destinationIata.value = 'MAD';
        controller.isCarrierEu.value = true;
        controller.setDisruptionType(DisruptionType.delay);
        controller.setDelayMinutes(110); // 1h 50m

        final elig = controller.eligibility.value!;
        expect(elig.isEligible, isFalse);
        expect(elig.amountEur, equals(0.0));
      },
    );

    test('Evaluates cancellation with under 7 days notice as eligible', () {
      controller.loadPresetScenario(2); // AMS -> FCO, 3 days notice
      final elig = controller.eligibility.value!;

      expect(elig.isEligible, isTrue);
      expect(elig.amountEur, equals(400.0));
    });

    test('Evaluates cancellation with over 14 days notice as exempt from cash payout', () {
      controller.originIata.value = 'AMS';
      controller.destinationIata.value = 'FCO';
      controller.isCarrierEu.value = true;
      controller.setDisruptionType(DisruptionType.cancellation);
      controller.setCancellationNoticeDays(18); // 18 days notice

      final elig = controller.eligibility.value!;
      expect(elig.isEligible, isFalse);
      expect(elig.amountEur, equals(0.0));
    });

    test('Evaluates involuntary denied boarding as immediate statutory compensation', () {
      controller.originIata.value = 'FRA';
      controller.destinationIata.value = 'CDG';
      controller.isCarrierEu.value = true;
      controller.setDisruptionType(DisruptionType.deniedBoarding);

      final elig = controller.eligibility.value!;
      expect(elig.isEligible, isTrue);
      expect(elig.amountEur, equals(250.0));
    });

    test('Certified extraordinary circumstances exempt cash compensation under Art. 5(3)', () {
      controller.loadPresetScenario(4); // Blizzard closure
      final elig = controller.eligibility.value!;

      expect(elig.isEligible, isFalse);
      expect(elig.amountEur, equals(0.0));
      expect(elig.airlineDefenseRisk, contains('High'));
      expect(
        elig.dutyOfCareSummary,
        contains('Right to Care remains mandatory'),
      );
    });

    test(
      'Non-EU flight outside EU jurisdiction falls under Montreal Convention',
      () {
        controller.loadPresetScenario(3); // DXB -> JFK, Emirates
        final elig = controller.eligibility.value!;

        expect(elig.isEligible, isFalse);
        expect(elig.primaryRegulation, Jurisdiction.montrealConvention);
        expect(
          elig.eligibilityReason,
          contains('Montreal Convention 1999 Article 19'),
        );
      },
    );

    test('Generates formal statutory claim notice citing binding case law', () {
      controller.loadPresetScenario(1); // CDG -> JFK
      final letter = controller.eligibility.value!.claimLetterTemplate;

      expect(letter, contains('FORMAL NOTICE OF STATUTORY CLAIM'));
      expect(letter, contains('AF 006'));
      expect(letter, contains('€600'));
      expect(letter, contains('Sturgeon v Condor'));
      expect(letter, contains('14 calendar days'));
    });

    test('Saves, loads, updates status and deletes claim', () async {
      controller.loadPresetScenario(0);
      await controller.saveCurrentClaim('trip_hunza_7d');

      expect(controller.savedClaims.length, equals(1));
      final saved = controller.savedClaims.first;
      expect(saved.flightNumber, equals('BA 902'));
      expect(saved.status, equals(ClaimStatus.draft));

      // Update status
      await controller.updateClaimStatus(
        saved.id,
        ClaimStatus.submitted,
        'trip_hunza_7d',
      );
      expect(
        controller.savedClaims.first.status,
        equals(ClaimStatus.submitted),
      );

      // Delete claim
      await controller.deleteClaim(saved.id, 'trip_hunza_7d');
      expect(controller.savedClaims.isEmpty, isTrue);
    });

    test(
      'Populates flight parameters directly from a TravelDocument entity',
      () {
        const doc = TravelDocument(
          id: 'doc_1',
          tripId: 'trip_swiss_4d',
          type: 'Flight',
          title: 'Swiss Air Flight LX-18',
          originIata: 'ZRH',
          destinationIata: 'JFK',
          flightOrBookingNumber: 'LX-18',
          gate: 'E22',
          seat: '4K',
          boardingTime: '12:30 PM',
          pnrCode: 'SW-98124',
          carrierName: 'Swiss International Air Lines',
          qrPayload: 'LX18-ZRH-JFK',
          notes: '',
        );

        controller.populateFromDocument(doc);

        expect(controller.flightNumber.value, equals('LX-18'));
        expect(
          controller.carrierName.value,
          equals('Swiss International Air Lines'),
        );
        expect(controller.originIata.value, equals('ZRH'));
        expect(controller.destinationIata.value, equals('JFK'));
        expect(controller.bookingReference.value, equals('SW-98124'));
      },
    );
  });
}

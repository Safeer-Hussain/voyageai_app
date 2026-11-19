import '../../domain/entities/flight_claim.dart';
import '../../domain/repositories/flight_claim_repository.dart';
import '../datasources/local_storage_datasource.dart';

class FlightClaimRepositoryImpl implements FlightClaimRepository {
  final LocalStorageDatasource _datasource;

  FlightClaimRepositoryImpl(this._datasource);

  @override
  Future<List<FlightClaim>> getClaimsForTrip(String tripId) async {
    final maps = await _datasource.getFlightClaimsForTrip(tripId);
    return maps.map((m) => FlightClaim.fromMap(m)).toList();
  }

  @override
  Future<FlightClaim?> getClaimById(String id) async {
    final map = await _datasource.getFlightClaimById(id);
    if (map == null) return null;
    return FlightClaim.fromMap(map);
  }

  @override
  Future<void> saveClaim(FlightClaim claim) async {
    await _datasource.insertFlightClaim(claim.toMap());
  }

  @override
  Future<void> updateClaimStatus(String claimId, ClaimStatus status) async {
    await _datasource.updateFlightClaimStatus(claimId, status.name);
  }

  @override
  Future<void> deleteClaim(String claimId) async {
    await _datasource.deleteFlightClaim(claimId);
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
    final originAirport = AirportCatalog.findByIata(originIata);
    final destAirport = AirportCatalog.findByIata(destinationIata);

    // Calculate distance
    double distanceKm = 1200.0; // sensible default
    if (originAirport != null && destAirport != null) {
      distanceKm = AirportCatalog.calculateDistanceKm(
        lat1: originAirport.latitude,
        lon1: originAirport.longitude,
        lat2: destAirport.latitude,
        lon2: destAirport.longitude,
      );
    } else {
      // Estimate based on standard international hops
      distanceKm = 1800.0;
    }

    final bool isOriginEu = originAirport?.isEu ?? false;
    final bool isOriginUk = originAirport?.isUk ?? false;
    final bool isDestEu = destAirport?.isEu ?? false;
    final bool isDestUk = destAirport?.isUk ?? false;

    // Jurisdiction determination
    Jurisdiction jurisdiction = Jurisdiction.none;
    if (isOriginEu) {
      jurisdiction = Jurisdiction.eu261;
    } else if (isOriginUk) {
      jurisdiction = Jurisdiction.uk261;
    } else if (isDestEu && isCarrierEu) {
      jurisdiction = Jurisdiction.eu261;
    } else if (isDestUk && isCarrierEu) {
      jurisdiction = Jurisdiction.uk261;
    } else {
      jurisdiction = Jurisdiction.montrealConvention;
    }

    // Determine Distance Tier
    final bool isIntraEu = isOriginEu && isDestEu;
    DistanceTier tier;
    if (distanceKm <= 1500) {
      tier = DistanceTier.shortHaul;
    } else if (distanceKm <= 3500 || isIntraEu) {
      tier = DistanceTier.mediumHaul;
    } else {
      tier = DistanceTier.longHaul;
    }

    // Evaluation Logic
    bool isEligible = false;
    double amountEur = 0.0;
    double amountGbp = 0.0;
    String reason = '';
    String defenseRisk = 'Low (Technical faults are carrier responsibility)';
    final List<String> articles = [];
    String dutyOfCare = '';

    if (jurisdiction == Jurisdiction.eu261 ||
        jurisdiction == Jurisdiction.uk261) {
      final isUk = jurisdiction == Jurisdiction.uk261;

      if (isExtraordinary) {
        isEligible = false;
        amountEur = 0.0;
        amountGbp = 0.0;
        reason = 'Flight disruption was caused by certified extraordinary circumstances (severe weather, ATC strike, or security threat). Statutory cash compensation is legally exempt under Article 5(3).';
        defenseRisk = 'High (Airline will invoke Force Majeure / Extraordinary Circumstances defense).';
        dutyOfCare = 'Right to Care remains mandatory under Article 9: Meals, refreshments, free communications (2 phone calls/emails), and overnight hotel accommodation if required.';
        articles.add(
          isUk
              ? 'The Air Passenger Rights Regs 2019 Reg. 5(3)'
              : 'EC 261/2004 Article 5(3)',
        );
        articles.add(
          isUk
              ? 'The Air Passenger Rights Regs 2019 Reg. 9'
              : 'EC 261/2004 Article 9',
        );
      } else {
        switch (disruptionType) {
          case DisruptionType.delay:
          case DisruptionType.missedConnection:
            if (delayMinutes >= 180) {
              isEligible = true;
              if (tier == DistanceTier.shortHaul) {
                amountEur = 250.0;
                amountGbp = 220.0;
                reason =
                    'Arrival delay of ${delayMinutes ~/ 60}h ${delayMinutes % 60}m exceeds 3-hour threshold on short-haul route (${distanceKm.toStringAsFixed(0)} km). Full statutory compensation applies.';
              } else if (tier == DistanceTier.mediumHaul) {
                amountEur = 400.0;
                amountGbp = 350.0;
                reason =
                    'Arrival delay of ${delayMinutes ~/ 60}h ${delayMinutes % 60}m exceeds 3-hour threshold on medium-haul route (${distanceKm.toStringAsFixed(0)} km). Full statutory compensation applies.';
              } else {
                if (delayMinutes < 240) {
                  amountEur = 300.0;
                  amountGbp = 260.0;
                  reason =
                      'Arrival delay of ${delayMinutes ~/ 60}h ${delayMinutes % 60}m is between 3 and 4 hours on long-haul route (${distanceKm.toStringAsFixed(0)} km). 50% statutory rate applies under Art. 7(2).';
                } else {
                  amountEur = 600.0;
                  amountGbp = 520.0;
                  reason =
                      'Arrival delay of ${delayMinutes ~/ 60}h ${delayMinutes % 60}m exceeds 4 hours on long-haul route (${distanceKm.toStringAsFixed(0)} km). Maximum statutory compensation applies.';
                }
              }
              articles.add(
                isUk
                    ? 'The Air Passenger Rights Regs 2019 Reg. 7'
                    : 'EC 261/2004 Article 7',
              );
              articles.add('CJEU Sturgeon Joined Cases C-402/07 & C-432/07');
              if (disruptionType == DisruptionType.missedConnection) {
                articles.add('CJEU Folkerts Case C-11/11 (Missed Connection)');
              }
            } else {
              isEligible = false;
              amountEur = 0.0;
              amountGbp = 0.0;
              reason =
                  'Arrival delay of ${delayMinutes ~/ 60}h ${delayMinutes % 60}m is under statutory 3-hour threshold. No monetary compensation is legally mandated.';
            }
            break;

          case DisruptionType.cancellation:
            final notice = cancellationNoticeDays ?? 0;
            if (notice > 14) {
              isEligible = false;
              amountEur = 0.0;
              amountGbp = 0.0;
              reason =
                  'Cancellation notified $notice days prior to departure (more than 14 days notice). Statutory cash compensation is exempt under Article 5(1)(c)(i); passenger is entitled to full ticket refund or rerouting.';
            } else {
              isEligible = true;
              if (tier == DistanceTier.shortHaul) {
                amountEur = 250.0;
                amountGbp = 220.0;
              } else if (tier == DistanceTier.mediumHaul) {
                amountEur = 400.0;
                amountGbp = 350.0;
              } else {
                amountEur = 600.0;
                amountGbp = 520.0;
              }
              reason =
                  'Flight cancelled with only $notice days notice without extraordinary circumstances. Statutory compensation applies under Article 5(1)(c).';
              articles.add(
                isUk
                    ? 'The Air Passenger Rights Regs 2019 Reg. 5 & 7'
                    : 'EC 261/2004 Articles 5 & 7',
              );
            }
            break;

          case DisruptionType.deniedBoarding:
            isEligible = true;
            if (tier == DistanceTier.shortHaul) {
              amountEur = 250.0;
              amountGbp = 220.0;
            } else if (tier == DistanceTier.mediumHaul) {
              amountEur = 400.0;
              amountGbp = 350.0;
            } else {
              amountEur = 600.0;
              amountGbp = 520.0;
            }
            reason = 'Involuntary denied boarding (overbooking). Statutory compensation is payable immediately under Article 4 without exception.';
            articles.add(
              isUk
                  ? 'The Air Passenger Rights Regs 2019 Reg. 4 & 7'
                  : 'EC 261/2004 Articles 4 & 7',
            );
            break;
        }

        // Duty of Care
        if (delayMinutes >= 120 ||
            disruptionType == DisruptionType.cancellation ||
            disruptionType == DisruptionType.deniedBoarding) {
          dutyOfCare = 'Full Right to Care active: Free meals & refreshments proportional to waiting time, 2 phone calls/emails, and hotel accommodation with ground transport if delayed overnight.';
          articles.add(
            isUk
                ? 'The Air Passenger Rights Regs 2019 Reg. 9'
                : 'EC 261/2004 Article 9',
          );
        } else {
          dutyOfCare = 'Delay is under 2 hours. Duty of care is not yet mandated under statutory rules.';
        }
      }
    } else {
      // Montreal Convention
      isEligible = false;
      amountEur = 0.0;
      amountGbp = 0.0;
      reason = 'Flight is outside EU261/UK261 territorial jurisdiction (non-EU/UK origin and non-Community carrier). Covered under Montreal Convention 1999 Article 19: Damages may be claimed for provable expenses up to 5,346 SDR (Special Drawing Rights).';
      dutyOfCare = 'Airline conditions of carriage and Montreal Convention Article 19 apply. Retain all hotel, food, and transport receipts.';
      articles.add('Montreal Convention 1999 Article 19 (Delay Liability)');
      articles.add('ICAO Annex 9 (Facilitation of Air Transport)');
      defenseRisk = 'Moderate (Requires itemized proof of economic loss)';
    }

    // Compute USD equivalent (using 1 EUR = ~1.08 USD, 1 GBP = ~1.26 USD)
    final double amountUsd = amountEur * 1.08;

    final tempEligibility = CompensationEligibility(
      isEligible: isEligible,
      amountEur: amountEur,
      amountGbp: amountGbp,
      amountUsdEquivalent: amountUsd,
      primaryRegulation: jurisdiction,
      distanceKm: distanceKm,
      distanceTier: tier,
      dutyOfCareSummary: dutyOfCare,
      applicableArticles: articles,
      eligibilityReason: reason,
      airlineDefenseRisk: defenseRisk,
      claimLetterTemplate: '',
    );

    // Generate formal legal claim letter
    final claimLetter = generateClaimLetter(
      flightNumber: flightNumber ?? 'FL-000',
      carrierName: carrierName ?? 'Operating Carrier',
      originIata: originIata,
      destinationIata: destinationIata,
      flightDate: flightDate ?? DateTime.now().toString().substring(0, 10),
      passengerName: passengerName ?? 'Passenger',
      bookingReference: bookingReference ?? 'PNR-XXXXXX',
      disruptionType: disruptionType,
      delayMinutes: delayMinutes,
      eligibility: tempEligibility,
    );

    return CompensationEligibility(
      isEligible: isEligible,
      amountEur: amountEur,
      amountGbp: amountGbp,
      amountUsdEquivalent: amountUsd,
      primaryRegulation: jurisdiction,
      distanceKm: distanceKm,
      distanceTier: tier,
      dutyOfCareSummary: dutyOfCare,
      applicableArticles: articles,
      eligibilityReason: reason,
      airlineDefenseRisk: defenseRisk,
      claimLetterTemplate: claimLetter,
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
    final regulationTitle = eligibility.primaryRegulation == Jurisdiction.uk261
        ? 'The Air Passenger Rights and Air Travel Organisers\' Licensing (Amendment) (EU Exit) Regulations 2019'
        : 'Regulation (EC) No 261/2004 of the European Parliament and of the Council';

    final compensationString =
        eligibility.primaryRegulation == Jurisdiction.uk261
        ? '£${eligibility.amountGbp.toStringAsFixed(0)}'
        : '€${eligibility.amountEur.toStringAsFixed(0)}';

    final disruptionDesc = disruptionType == DisruptionType.delay
        ? 'delayed on arrival by ${delayMinutes ~/ 60} hours and ${delayMinutes % 60} minutes'
        : disruptionType == DisruptionType.cancellation
        ? 'cancelled'
        : disruptionType == DisruptionType.deniedBoarding
        ? 'subject to involuntary denied boarding'
        : 'delayed at connecting hub causing a missed connection';

    final legalReferences = eligibility.applicableArticles.join('\n- ');

    return '''
FORMAL NOTICE OF STATUTORY CLAIM
Pursuant to $regulationTitle

Date: ${DateTime.now().toIso8601String().substring(0, 10)}
To: Customer Relations & Legal Department, $carrierName

RE: Flight Compensation Claim - Flight $flightNumber ($originIata to $destinationIata)
Booking Reference (PNR): $bookingReference
Passenger Name: $passengerName
Scheduled Departure Date: $flightDate

Dear Customer Relations Team,

I am writing to formally request statutory compensation regarding flight $flightNumber from $originIata to $destinationIata on $flightDate, which was $disruptionDesc.

According to statutory flight distance calculation, the Great-Circle distance of this route is approximately ${eligibility.distanceKm.toStringAsFixed(0)} km (${eligibility.distanceTier.name.toUpperCase()}).

Under the binding provisions of $regulationTitle and established jurisprudence (including Sturgeon v Condor Joined Cases C-402/07 & C-432/07 and Wallentin-Hermann v Alitalia Case C-549/07), I am legally entitled to fixed statutory compensation in the amount of:

$compensationString per passenger.

Applicable Statutory Instruments & Precedents:
- $legalReferences

Technical defects, ordinary aircraft maintenance, and crew scheduling issues do not constitute "extraordinary circumstances" under the ruling of the Court of Justice of the European Union.

I kindly request that you settle this claim by direct bank transfer to my designated account within 14 calendar days of receipt of this notice.

Should you fail to respond or settle this statutory claim within 14 days, I reserve the right to escalate this complaint to the relevant National Enforcement Body (NEB) or initiate proceedings through the European Small Claims Procedure or equivalent jurisdictional court without further notice.

Yours sincerely,

$passengerName
Booking Reference: $bookingReference
''';
  }
}

import 'dart:math';

enum DisruptionType { delay, cancellation, deniedBoarding, missedConnection }

enum Jurisdiction { eu261, uk261, montrealConvention, none }

enum DistanceTier {
  shortHaul, // <= 1,500 km
  mediumHaul, // 1,500 km - 3,500 km or intra-EU > 1,500 km
  longHaul, // > 3,500 km
}

enum ClaimStatus { draft, submitted, underReview, settled, rejected }

class AirportInfo {
  final String iata;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool isEu;
  final bool isUk;

  const AirportInfo({
    required this.iata,
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isEu,
    required this.isUk,
  });
}

class AirportCatalog {
  static const List<AirportInfo> majorAirports = [
    // EU / EEA Airports
    AirportInfo(
      iata: 'CDG',
      name: 'Charles de Gaulle Airport',
      city: 'Paris',
      country: 'France',
      latitude: 49.0097,
      longitude: 2.5479,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'FRA',
      name: 'Frankfurt Airport',
      city: 'Frankfurt',
      country: 'Germany',
      latitude: 50.0379,
      longitude: 8.5622,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'AMS',
      name: 'Amsterdam Airport Schiphol',
      city: 'Amsterdam',
      country: 'Netherlands',
      latitude: 52.3105,
      longitude: 4.7683,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'MAD',
      name: 'Adolfo Suarez Madrid-Barajas',
      city: 'Madrid',
      country: 'Spain',
      latitude: 40.4839,
      longitude: -3.5680,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'FCO',
      name: 'Leonardo da Vinci-Fiumicino',
      city: 'Rome',
      country: 'Italy',
      latitude: 41.8003,
      longitude: 12.2389,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'ZRH',
      name: 'Zurich Airport',
      city: 'Zurich',
      country: 'Switzerland',
      latitude: 47.4582,
      longitude: 8.5555,
      isEu: true, // Switzerland participates in EU261 via bilateral agreements
      isUk: false,
    ),
    AirportInfo(
      iata: 'VIE',
      name: 'Vienna International Airport',
      city: 'Vienna',
      country: 'Austria',
      latitude: 48.1103,
      longitude: 16.5697,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'DUB',
      name: 'Dublin Airport',
      city: 'Dublin',
      country: 'Ireland',
      latitude: 53.4264,
      longitude: -6.2499,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'ATH',
      name: 'Athens International Airport',
      city: 'Athens',
      country: 'Greece',
      latitude: 37.9364,
      longitude: 23.9445,
      isEu: true,
      isUk: false,
    ),
    AirportInfo(
      iata: 'MUC',
      name: 'Munich Airport',
      city: 'Munich',
      country: 'Germany',
      latitude: 48.3537,
      longitude: 11.7750,
      isEu: true,
      isUk: false,
    ),

    // UK Airports
    AirportInfo(
      iata: 'LHR',
      name: 'London Heathrow Airport',
      city: 'London',
      country: 'United Kingdom',
      latitude: 51.4700,
      longitude: -0.4543,
      isEu: false,
      isUk: true,
    ),
    AirportInfo(
      iata: 'LGW',
      name: 'London Gatwick Airport',
      city: 'London',
      country: 'United Kingdom',
      latitude: 51.1537,
      longitude: -0.1821,
      isEu: false,
      isUk: true,
    ),
    AirportInfo(
      iata: 'MAN',
      name: 'Manchester Airport',
      city: 'Manchester',
      country: 'United Kingdom',
      latitude: 53.3537,
      longitude: -2.2750,
      isEu: false,
      isUk: true,
    ),
    AirportInfo(
      iata: 'EDI',
      name: 'Edinburgh Airport',
      city: 'Edinburgh',
      country: 'United Kingdom',
      latitude: 55.9500,
      longitude: -3.3725,
      isEu: false,
      isUk: true,
    ),

    // North America & Global
    AirportInfo(
      iata: 'JFK',
      name: 'John F. Kennedy International',
      city: 'New York',
      country: 'United States',
      latitude: 40.6413,
      longitude: -73.7781,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'LAX',
      name: 'Los Angeles International',
      city: 'Los Angeles',
      country: 'United States',
      latitude: 33.9416,
      longitude: -118.4085,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'ORD',
      name: "O'Hare International Airport",
      city: 'Chicago',
      country: 'United States',
      latitude: 41.9742,
      longitude: -87.9073,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'DXB',
      name: 'Dubai International Airport',
      city: 'Dubai',
      country: 'United Arab Emirates',
      latitude: 25.2532,
      longitude: 55.3657,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'DOH',
      name: 'Hamad International Airport',
      city: 'Doha',
      country: 'Qatar',
      latitude: 25.2731,
      longitude: 51.6081,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'HND',
      name: 'Tokyo Haneda Airport',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.5494,
      longitude: 139.7798,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'SIN',
      name: 'Singapore Changi Airport',
      city: 'Singapore',
      country: 'Singapore',
      latitude: 1.3644,
      longitude: 103.9915,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'BKK',
      name: 'Suvarnabhumi Airport',
      city: 'Bangkok',
      country: 'Thailand',
      latitude: 13.6900,
      longitude: 100.7501,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'ISB',
      name: 'Islamabad International Airport',
      city: 'Islamabad',
      country: 'Pakistan',
      latitude: 33.5605,
      longitude: 72.8517,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'LHE',
      name: 'Allama Iqbal International',
      city: 'Lahore',
      country: 'Pakistan',
      latitude: 31.5216,
      longitude: 74.4036,
      isEu: false,
      isUk: false,
    ),
    AirportInfo(
      iata: 'KHI',
      name: 'Jinnah International Airport',
      city: 'Karachi',
      country: 'Pakistan',
      latitude: 24.9065,
      longitude: 67.1608,
      isEu: false,
      isUk: false,
    ),
  ];

  static AirportInfo? findByIata(String iata) {
    final clean = iata.trim().toUpperCase();
    for (final airport in majorAirports) {
      if (airport.iata == clean) return airport;
    }
    return null;
  }

  /// Calculates the Great-Circle distance (Haversine formula) in kilometers.
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}

class CompensationEligibility {
  final bool isEligible;
  final double amountEur;
  final double amountGbp;
  final double amountUsdEquivalent;
  final Jurisdiction primaryRegulation;
  final double distanceKm;
  final DistanceTier distanceTier;
  final String dutyOfCareSummary;
  final List<String> applicableArticles;
  final String eligibilityReason;
  final String airlineDefenseRisk;
  final String claimLetterTemplate;

  const CompensationEligibility({
    required this.isEligible,
    required this.amountEur,
    required this.amountGbp,
    required this.amountUsdEquivalent,
    required this.primaryRegulation,
    required this.distanceKm,
    required this.distanceTier,
    required this.dutyOfCareSummary,
    required this.applicableArticles,
    required this.eligibilityReason,
    required this.airlineDefenseRisk,
    required this.claimLetterTemplate,
  });
}

class FlightClaim {
  final String id;
  final String tripId;
  final String flightNumber;
  final String carrierName;
  final String originIata;
  final String destinationIata;
  final bool isCarrierEu;
  final String flightDate;
  final DisruptionType disruptionType;
  final int delayMinutes;
  final int? cancellationNoticeDays;
  final bool isExtraordinary;
  final String passengerName;
  final String bookingReference;
  final bool isEligible;
  final double compensationEur;
  final double compensationGbp;
  final Jurisdiction primaryJurisdiction;
  final ClaimStatus status;
  final String claimLetter;
  final String notes;
  final int createdAt;

  const FlightClaim({
    required this.id,
    required this.tripId,
    required this.flightNumber,
    required this.carrierName,
    required this.originIata,
    required this.destinationIata,
    required this.isCarrierEu,
    required this.flightDate,
    required this.disruptionType,
    required this.delayMinutes,
    this.cancellationNoticeDays,
    required this.isExtraordinary,
    required this.passengerName,
    required this.bookingReference,
    required this.isEligible,
    required this.compensationEur,
    required this.compensationGbp,
    required this.primaryJurisdiction,
    required this.status,
    required this.claimLetter,
    required this.notes,
    required this.createdAt,
  });

  FlightClaim copyWith({
    String? id,
    String? tripId,
    String? flightNumber,
    String? carrierName,
    String? originIata,
    String? destinationIata,
    bool? isCarrierEu,
    String? flightDate,
    DisruptionType? disruptionType,
    int? delayMinutes,
    int? cancellationNoticeDays,
    bool? isExtraordinary,
    String? passengerName,
    String? bookingReference,
    bool? isEligible,
    double? compensationEur,
    double? compensationGbp,
    Jurisdiction? primaryJurisdiction,
    ClaimStatus? status,
    String? claimLetter,
    String? notes,
    int? createdAt,
  }) {
    return FlightClaim(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      flightNumber: flightNumber ?? this.flightNumber,
      carrierName: carrierName ?? this.carrierName,
      originIata: originIata ?? this.originIata,
      destinationIata: destinationIata ?? this.destinationIata,
      isCarrierEu: isCarrierEu ?? this.isCarrierEu,
      flightDate: flightDate ?? this.flightDate,
      disruptionType: disruptionType ?? this.disruptionType,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      cancellationNoticeDays:
          cancellationNoticeDays ?? this.cancellationNoticeDays,
      isExtraordinary: isExtraordinary ?? this.isExtraordinary,
      passengerName: passengerName ?? this.passengerName,
      bookingReference: bookingReference ?? this.bookingReference,
      isEligible: isEligible ?? this.isEligible,
      compensationEur: compensationEur ?? this.compensationEur,
      compensationGbp: compensationGbp ?? this.compensationGbp,
      primaryJurisdiction: primaryJurisdiction ?? this.primaryJurisdiction,
      status: status ?? this.status,
      claimLetter: claimLetter ?? this.claimLetter,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'flight_number': flightNumber,
      'carrier_name': carrierName,
      'origin_iata': originIata,
      'destination_iata': destinationIata,
      'is_carrier_eu': isCarrierEu ? 1 : 0,
      'flight_date': flightDate,
      'disruption_type': disruptionType.name,
      'delay_minutes': delayMinutes,
      'cancellation_notice_days': cancellationNoticeDays,
      'is_extraordinary': isExtraordinary ? 1 : 0,
      'passenger_name': passengerName,
      'booking_reference': bookingReference,
      'is_eligible': isEligible ? 1 : 0,
      'compensation_eur': compensationEur,
      'compensation_gbp': compensationGbp,
      'primary_jurisdiction': primaryJurisdiction.name,
      'status': status.name,
      'claim_letter': claimLetter,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory FlightClaim.fromMap(Map<String, dynamic> map) {
    return FlightClaim(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      flightNumber: map['flight_number'] as String,
      carrierName: map['carrier_name'] as String,
      originIata: map['origin_iata'] as String,
      destinationIata: map['destination_iata'] as String,
      isCarrierEu: (map['is_carrier_eu'] as int? ?? 0) == 1,
      flightDate: map['flight_date'] as String,
      disruptionType: DisruptionType.values.firstWhere(
        (e) => e.name == map['disruption_type'],
        orElse: () => DisruptionType.delay,
      ),
      delayMinutes: (map['delay_minutes'] as num? ?? 0).toInt(),
      cancellationNoticeDays: map['cancellation_notice_days'] as int?,
      isExtraordinary: (map['is_extraordinary'] as int? ?? 0) == 1,
      passengerName: map['passenger_name'] as String,
      bookingReference: map['booking_reference'] as String,
      isEligible: (map['is_eligible'] as int? ?? 0) == 1,
      compensationEur: (map['compensation_eur'] as num? ?? 0.0).toDouble(),
      compensationGbp: (map['compensation_gbp'] as num? ?? 0.0).toDouble(),
      primaryJurisdiction: Jurisdiction.values.firstWhere(
        (e) => e.name == map['primary_jurisdiction'],
        orElse: () => Jurisdiction.eu261,
      ),
      status: ClaimStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ClaimStatus.draft,
      ),
      claimLetter: map['claim_letter'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: (map['created_at'] as num? ?? 0).toInt(),
    );
  }
}

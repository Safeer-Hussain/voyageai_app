class TravelDocument {
  final String id;
  final String tripId;
  final String type; // Flight, Hotel, Rail, Passport
  final String title;
  final String originIata;
  final String destinationIata;
  final String flightOrBookingNumber;
  final String gate;
  final String seat;
  final String boardingTime;
  final String pnrCode;
  final String carrierName;
  final String qrPayload;
  final String notes;

  const TravelDocument({
    required this.id,
    required this.tripId,
    required this.type,
    required this.title,
    required this.originIata,
    required this.destinationIata,
    required this.flightOrBookingNumber,
    required this.gate,
    required this.seat,
    required this.boardingTime,
    required this.pnrCode,
    required this.carrierName,
    required this.qrPayload,
    required this.notes,
  });

  TravelDocument copyWith({
    String? id,
    String? tripId,
    String? type,
    String? title,
    String? originIata,
    String? destinationIata,
    String? flightOrBookingNumber,
    String? gate,
    String? seat,
    String? boardingTime,
    String? pnrCode,
    String? carrierName,
    String? qrPayload,
    String? notes,
  }) {
    return TravelDocument(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      type: type ?? this.type,
      title: title ?? this.title,
      originIata: originIata ?? this.originIata,
      destinationIata: destinationIata ?? this.destinationIata,
      flightOrBookingNumber:
          flightOrBookingNumber ?? this.flightOrBookingNumber,
      gate: gate ?? this.gate,
      seat: seat ?? this.seat,
      boardingTime: boardingTime ?? this.boardingTime,
      pnrCode: pnrCode ?? this.pnrCode,
      carrierName: carrierName ?? this.carrierName,
      qrPayload: qrPayload ?? this.qrPayload,
      notes: notes ?? this.notes,
    );
  }
}

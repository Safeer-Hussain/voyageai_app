import '../../domain/entities/document.dart';

class DocumentModel extends TravelDocument {
  const DocumentModel({
    required super.id,
    required super.tripId,
    required super.type,
    required super.title,
    required super.originIata,
    required super.destinationIata,
    required super.flightOrBookingNumber,
    required super.gate,
    required super.seat,
    required super.boardingTime,
    required super.pnrCode,
    required super.carrierName,
    required super.qrPayload,
    required super.notes,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      originIata: map['origin_iata'] as String,
      destinationIata: map['destination_iata'] as String,
      flightOrBookingNumber: map['flight_or_booking_number'] as String,
      gate: map['gate'] as String,
      seat: map['seat'] as String,
      boardingTime: map['boarding_time'] as String,
      pnrCode: map['pnr_code'] as String,
      carrierName: map['carrier_name'] as String,
      qrPayload: map['qr_payload'] as String,
      notes: map['notes'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'type': type,
      'title': title,
      'origin_iata': originIata,
      'destination_iata': destinationIata,
      'flight_or_booking_number': flightOrBookingNumber,
      'gate': gate,
      'seat': seat,
      'boarding_time': boardingTime,
      'pnr_code': pnrCode,
      'carrier_name': carrierName,
      'qr_payload': qrPayload,
      'notes': notes,
    };
  }

  factory DocumentModel.fromEntity(TravelDocument doc) {
    return DocumentModel(
      id: doc.id,
      tripId: doc.tripId,
      type: doc.type,
      title: doc.title,
      originIata: doc.originIata,
      destinationIata: doc.destinationIata,
      flightOrBookingNumber: doc.flightOrBookingNumber,
      gate: doc.gate,
      seat: doc.seat,
      boardingTime: doc.boardingTime,
      pnrCode: doc.pnrCode,
      carrierName: doc.carrierName,
      qrPayload: doc.qrPayload,
      notes: doc.notes,
    );
  }
}

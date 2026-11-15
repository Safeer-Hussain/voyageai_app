import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/domain/entities/document.dart';
import 'package:voyage_ai_app/domain/repositories/document_repository.dart';
import 'package:voyage_ai_app/presentation/document_vault/controllers/document_vault_controller.dart';

class MockDocumentRepository implements DocumentRepository {
  List<TravelDocument> docs = [
    const TravelDocument(
      id: 'doc_1',
      tripId: 'trip_hunza_7d',
      type: 'Flight',
      title: 'PIA PK-451',
      originIata: 'LHE',
      destinationIata: 'KDU',
      flightOrBookingNumber: 'PK-451',
      gate: 'B4',
      seat: '14A',
      boardingTime: '06:45 AM',
      pnrCode: 'VY-78291',
      carrierName: 'PIA',
      qrPayload: 'PAYLOAD',
      notes: 'Notes',
    ),
    const TravelDocument(
      id: 'doc_2',
      tripId: 'trip_hunza_7d',
      type: 'Hotel',
      title: 'Serena Inn',
      originIata: 'GB',
      destinationIata: 'HNZ',
      flightOrBookingNumber: 'SRN-88410',
      gate: 'Lobby',
      seat: 'Suite 302',
      boardingTime: '02:00 PM',
      pnrCode: 'SRN-88410',
      carrierName: 'Serena',
      qrPayload: 'PAYLOAD',
      notes: 'Notes',
    ),
  ];

  @override
  Future<List<TravelDocument>> getDocumentsForTrip(String tripId) async =>
      docs.where((d) => d.tripId == tripId).toList();

  @override
  Future<void> addDocument(TravelDocument doc) async => docs.add(doc);

  @override
  Future<void> deleteDocument(String documentId) async =>
      docs.removeWhere((d) => d.id == documentId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDocumentRepository mockRepo;
  late DocumentVaultController controller;

  setUp(() async {
    Get.testMode = true;
    mockRepo = MockDocumentRepository();
    controller = DocumentVaultController(mockRepo);
    await controller.loadDocuments('trip_hunza_7d');
  });

  group('DocumentVaultController Unit Tests', () {
    test('Loads initial documents for the given expedition', () {
      expect(controller.documents.length, 2);
    });

    test('Filters documents by category correctly', () {
      controller.selectCategory('Flights');
      expect(controller.filteredDocuments.length, 1);
      expect(controller.filteredDocuments.first.type, 'Flight');

      controller.selectCategory('Hotel Stays');
      expect(controller.filteredDocuments.length, 1);
      expect(controller.filteredDocuments.first.type, 'Hotel');

      controller.selectCategory('All');
      expect(controller.filteredDocuments.length, 2);
    });

    test('addDocument vaults new boarding pass and updates list', () async {
      await controller.addDocument(
        tripId: 'trip_hunza_7d',
        type: 'Rail',
        title: 'Shinkansen Rail Pass',
        originIata: 'TYO',
        destinationIata: 'KYO',
        flightOrBookingNumber: 'NOZ-99',
        gate: 'Track 14',
        seat: 'Car 5, 12A',
        boardingTime: '09:00 AM',
        pnrCode: 'JR-12345',
        carrierName: 'JR Central',
        notes: 'Green Car ticket',
      );

      expect(controller.documents.length, 3);
      expect(controller.documents.last.pnrCode, 'JR-12345');
    });
  });
}

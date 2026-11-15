import '../entities/document.dart';

abstract class DocumentRepository {
  Future<List<TravelDocument>> getDocumentsForTrip(String tripId);
  Future<void> addDocument(TravelDocument doc);
  Future<void> deleteDocument(String documentId);
}

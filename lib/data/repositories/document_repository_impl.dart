import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final LocalStorageDatasource _datasource;

  DocumentRepositoryImpl(this._datasource);

  @override
  Future<List<TravelDocument>> getDocumentsForTrip(String tripId) async {
    return await _datasource.getDocumentsForTrip(tripId);
  }

  @override
  Future<void> addDocument(TravelDocument doc) async {
    await _datasource.insertDocument(DocumentModel.fromEntity(doc));
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await _datasource.deleteDocument(documentId);
  }
}

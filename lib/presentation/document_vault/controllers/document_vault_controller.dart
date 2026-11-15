import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/document.dart';
import '../../../domain/repositories/document_repository.dart';

class DocumentVaultController extends GetxController {
  final DocumentRepository _repository;

  DocumentVaultController(this._repository);

  final RxList<TravelDocument> documents = <TravelDocument>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isBrightnessBoosted = false.obs;

  static const List<String> categories = [
    'All',
    'Flights',
    'Hotel Stays',
    'Rail Passes',
    'Passport & Visas',
  ];

  Future<void> loadDocuments(String tripId) async {
    isLoading.value = true;
    try {
      final loaded = await _repository.getDocumentsForTrip(tripId);
      documents.assignAll(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  List<TravelDocument> get filteredDocuments {
    if (selectedCategory.value == 'All') {
      return documents;
    }
    return documents.where((doc) {
      if (selectedCategory.value == 'Flights') {
        return doc.type == 'Flight';
      }
      if (selectedCategory.value == 'Hotel Stays') {
        return doc.type == 'Hotel';
      }
      if (selectedCategory.value == 'Rail Passes') {
        return doc.type == 'Rail';
      }
      if (selectedCategory.value == 'Passport & Visas') {
        return doc.type == 'Passport';
      }
      return true;
    }).toList();
  }

  Future<bool> addDocument({
    required String tripId,
    required String type,
    required String title,
    required String originIata,
    required String destinationIata,
    required String flightOrBookingNumber,
    required String gate,
    required String seat,
    required String boardingTime,
    required String pnrCode,
    required String carrierName,
    required String notes,
  }) async {
    final newDoc = TravelDocument(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      type: type,
      title: title,
      originIata: originIata.toUpperCase(),
      destinationIata: destinationIata.toUpperCase(),
      flightOrBookingNumber: flightOrBookingNumber.toUpperCase(),
      gate: gate,
      seat: seat,
      boardingTime: boardingTime,
      pnrCode: pnrCode.toUpperCase(),
      carrierName: carrierName,
      qrPayload: 'DOC:$pnrCode|$carrierName|$originIata->$destinationIata',
      notes: notes,
    );

    documents.add(newDoc);
    documents.refresh();
    await _repository.addDocument(newDoc);

    AppFeedback.showSuccess(
      title: 'Pass Vaulted',
      message: '$title saved securely to offline vault.',
    );
    return true;
  }

  Future<void> copyPnr(String pnr) async {
    await Clipboard.setData(ClipboardData(text: pnr));
    AppFeedback.showSuccess(
      title: 'PNR Copied',
      message: 'Booking reference $pnr copied to clipboard.',
    );
  }

  void toggleBrightnessBoost() {
    isBrightnessBoosted.value = !isBrightnessBoosted.value;
  }
}

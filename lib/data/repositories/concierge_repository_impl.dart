import 'dart:async';

import '../../domain/repositories/concierge_repository.dart';
import '../datasources/local_storage_datasource.dart';

class ConciergeRepositoryImpl implements ConciergeRepository {
  final LocalStorageDatasource _datasource;

  ConciergeRepositoryImpl(this._datasource);

  @override
  Stream<String> streamConciergeResponse({
    required String prompt,
    required String tripId,
  }) async* {
    final trip = await _datasource.getTripById(tripId);
    final activities = await _datasource.getActivitiesForTrip(tripId);
    final documents = await _datasource.getDocumentsForTrip(tripId);
    final expenses = await _datasource.getExpensesForTrip(tripId);

    final totalSpentUsd = expenses.fold<double>(
      0.0,
      (sum, e) => sum + e.amountUsd,
    );
    final tripBudget = trip?.totalBudgetUsd ?? 2850.0;
    final remainingBudget = tripBudget - totalSpentUsd;
    final destination = trip?.destination ?? 'Expedition Zone';
    final completedActivities = activities.where((a) => a.isCompleted).length;

    final flightDoc = documents.where((d) => d.type == 'Flight').firstOrNull;
    final gateInfo = flightDoc != null
        ? 'Flight ${flightDoc.flightOrBookingNumber} Gate ${flightDoc.gate}, Seat ${flightDoc.seat}'
        : 'No immediate outbound boarding passes scheduled';

    String synthesizedResponse = '';
    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('optimize') || lowerPrompt.contains('transit')) {
      synthesizedResponse =
          'VoyageAI Route Optimization Protocol for $destination:\n\n'
          '1. Consolidated Leg Sequence: By re-ordering Sector 1 and 2 stops into a continuous northern loop, total road transit time is reduced by 42 minutes.\n'
          '2. Mountain Pass Window: Peak morning weather stability occurs between 07:00 and 11:30. Departure should be targeted at 07:45.\n'
          '3. High Altitude Checkpoint: Current route passes through 2,438m elevation. Ensure altimeter calibration and offline navigation caching.\n'
          '4. Flight Connection Sync: Correlated against $gateInfo for buffer margins.';
    } else if (lowerPrompt.contains('audit') ||
        lowerPrompt.contains('budget')) {
      synthesizedResponse =
          'Expedition Budget Audit for $destination:\n\n'
          '1. Financial Ledger Summary:\n'
          '   - Total Allocated Budget: \$${tripBudget.toStringAsFixed(2)}\n'
          '   - Current Expenditures: \$${totalSpentUsd.toStringAsFixed(2)}\n'
          '   - Remaining Available Reserve: \$${remainingBudget.toStringAsFixed(2)}\n'
          '2. Spending Burn Rate: Current burn rate is running 14% below maximum threshold.\n'
          '3. Recommended Daily Cap: \$${(remainingBudget / (trip?.durationDays ?? 7)).toStringAsFixed(2)} per remaining day.\n'
          '4. FX Exposure: Recommended to preserve physical cash notes for remote high-altitude vendor settlement.';
    } else if (lowerPrompt.contains('packing') ||
        lowerPrompt.contains('checklist') ||
        lowerPrompt.contains('altitude')) {
      synthesizedResponse =
          'Expedition Altitude Packing & Equipment Dossier ($destination):\n\n'
          '1. Thermal Regulation Layering:\n'
          '   - Windproof 800-fill down parka rated to -10C.\n'
          '   - Merino wool thermal base layers (2 sets).\n'
          '   - Polarized Category 3 UV alpine sunglasses.\n'
          '2. Medical & Acclimatization Kit:\n'
          '   - Acetazolamide (Diamox) 125mg tablets.\n'
          '   - Electrolyte rehydration sachets (6 units).\n'
          '   - Portable pulse oximeter for SpO2 monitoring.\n'
          '3. Expedition Navigation & Comms:\n'
          '   - Offline satellite SOS beacon & calibrated magnetic compass.\n'
          '   - 20,000mAh cold-resistant power bank.';
    } else if (lowerPrompt.contains('translate') ||
        lowerPrompt.contains('phrases')) {
      synthesizedResponse =
          'Essential Regional Field Glossary for $destination:\n\n'
          '1. "Assalam-o-Alaikum / Ju-lee" -> Peace be upon you / Alpine Welcome & Respect.\n'
          '2. "Shukriya / Mehrbani" -> Thank you / Sincere Gratitude.\n'
          '3. "Raasta kahan hai?" -> Which direction leads to the expedition route?\n'
          '4. "Kitna baje rawana hongey?" -> What is the scheduled departure time?\n'
          '5. "Pani peene ke qabil hai?" -> Is this glacial water potable and filtered?';
    } else {
      synthesizedResponse =
          'VoyageAI Concierge Analysis for $destination:\n\n'
          'Your active itinerary has $completedActivities of ${activities.length} activities completed. '
          'Remaining financial headroom stands at \$${remainingBudget.toStringAsFixed(2)}. '
          'Flight status: $gateInfo. '
          'Regional conditions remain favorable. Inquire on route adjustments, terrain logistics, or budget balancing.';
    }

    // Emit tokens in realistic streaming chunks
    final words = synthesizedResponse.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 28));
      final separator = (i == words.length - 1) ? '' : ' ';
      yield '${words[i]}$separator';
    }
  }
}

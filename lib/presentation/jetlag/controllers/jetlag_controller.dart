import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/circadian_protocol.dart';
import '../../../domain/repositories/jetlag_repository.dart';

class JetlagController extends GetxController {
  final JetlagRepository _repository;

  JetlagController(this._repository);

  final Rxn<JetlagPlan> activePlan = Rxn<JetlagPlan>();
  final RxString activeTripId = 'trip_hunza_7d'.obs;
  final RxBool isLoading = false.obs;

  static const List<Map<String, dynamic>> majorAirports = [
    {'city': 'New York (JFK)', 'tzOffset': -5},
    {'city': 'Los Angeles (LAX)', 'tzOffset': -8},
    {'city': 'London (LHR)', 'tzOffset': 0},
    {'city': 'Paris (CDG)', 'tzOffset': 1},
    {'city': 'Zurich (ZRH)', 'tzOffset': 1},
    {'city': 'Dubai (DXB)', 'tzOffset': 4},
    {'city': 'Islamabad (ISB)', 'tzOffset': 5},
    {'city': 'Karachi (KHI)', 'tzOffset': 5},
    {'city': 'Bangkok (BKK)', 'tzOffset': 7},
    {'city': 'Singapore (SIN)', 'tzOffset': 8},
    {'city': 'Tokyo (HND)', 'tzOffset': 9},
    {'city': 'Sydney (SYD)', 'tzOffset': 10},
    {'city': 'Honolulu (HNL)', 'tzOffset': -10},
  ];

  @override
  void onInit() {
    super.onInit();
    loadPlan(activeTripId.value);
  }

  Future<void> loadPlan(String tripId) async {
    activeTripId.value = tripId;
    isLoading.value = true;
    try {
      final plan = await _repository.getPlanForTrip(tripId);
      if (plan != null) {
        activePlan.value = plan;
      } else {
        // Synthesize default plan if trip does not have one yet
        final synthesized = _generateDefaultPlan(tripId);
        activePlan.value = synthesized;
        await _repository.savePlan(synthesized);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleCheckpoint(int dayOffset) async {
    final current = activePlan.value;
    if (current == null) return;

    final updatedDays = current.shiftDays.map((d) {
      if (d.dayOffset == dayOffset) {
        return d.copyWith(isCompleted: !d.isCompleted);
      }
      return d;
    }).toList();

    final updatedPlan = current.copyWith(shiftDays: updatedDays);
    activePlan.value = updatedPlan;

    final targetDay = updatedDays.firstWhere((d) => d.dayOffset == dayOffset);
    await _repository.toggleShiftDayCheckpoint(
      current.id,
      dayOffset,
      targetDay.isCompleted,
    );

    AppFeedback.showSuccess(
      title: targetDay.isCompleted
          ? 'Circadian Checkpoint Confirmed'
          : 'Checkpoint Pending',
      message:
          'Protocol milestone for Day $dayOffset marked as ${targetDay.isCompleted ? "achieved" : "incomplete"}.',
    );
  }

  Future<void> resetPlan() async {
    final current = activePlan.value;
    if (current == null) return;

    final updatedDays = current.shiftDays.map((d) {
      return d.copyWith(isCompleted: false);
    }).toList();

    final updatedPlan = current.copyWith(shiftDays: updatedDays);
    activePlan.value = updatedPlan;

    await _repository.resetPlan(current.id);

    AppFeedback.showInfo(
      title: 'Circadian Protocol Reset',
      message: 'All daily sleep shift checkpoints reset to pending.',
    );
  }

  Future<void> generateCustomPlan({
    required String originCity,
    required int originTzOffset,
    required String destinationCity,
    required int destinationTzOffset,
    required DateTime departureDate,
  }) async {
    int diff = destinationTzOffset - originTzOffset;
    if (diff > 12) diff -= 24;
    if (diff < -12) diff += 24;

    final direction = diff >= 0 ? 'Eastward' : 'Westward';
    final totalHourShift = diff.abs();
    final daysToAdapt =
        (direction == 'Eastward'
                ? (totalHourShift / 1.4).ceil()
                : (totalHourShift / 1.8).ceil())
            .clamp(2, 9);

    final shiftDays = _buildShiftDaysList(
      direction: direction,
      hourShift: totalHourShift,
      daysToAdapt: daysToAdapt,
    );

    final plan = JetlagPlan(
      id: 'jetlag_${DateTime.now().millisecondsSinceEpoch}',
      tripId: activeTripId.value,
      originCity: originCity,
      originTzOffset: originTzOffset,
      destinationCity: destinationCity,
      destinationTzOffset: destinationTzOffset,
      departureTimestamp: departureDate.millisecondsSinceEpoch,
      arrivalTimestamp: departureDate
          .add(const Duration(hours: 14))
          .millisecondsSinceEpoch,
      direction: direction,
      totalHourShift: totalHourShift,
      daysToAdapt: daysToAdapt,
      shiftDays: shiftDays,
    );

    activePlan.value = plan;
    await _repository.savePlan(plan);

    AppFeedback.showSuccess(
      title: 'Custom Circadian Plan Active',
      message:
          '$totalHourShift-Hour $direction shift protocol generated with $daysToAdapt adaptation phases.',
    );
  }

  List<CircadianShiftDay> _buildShiftDaysList({
    required String direction,
    required int hourShift,
    required int daysToAdapt,
  }) {
    final isEastward = direction == 'Eastward';

    return [
      CircadianShiftDay(
        dayOffset: -2,
        dayLabel: 'Pre-Departure Protocol 1 (Day -2)',
        targetBedtime: isEastward
            ? '21:30 (Home) - 45m Earlier'
            : '23:30 (Home) - 45m Later',
        targetWakeup: isEastward ? '06:00 (Home)' : '08:00 (Home)',
        lightExposureWindow: isEastward
            ? '06:30 - 09:30 (Bright Morning Sunlight)'
            : '16:00 - 19:00 (Afternoon / Evening Sun)',
        lightAvoidanceWindow: isEastward
            ? '19:30 - Bedtime (Blue-Blocker Glasses)'
            : '06:00 - 08:30 (Wear Dark Sunglasses)',
        caffeineCutoff: isEastward ? '13:00 (Early Cutoff)' : '15:30',
        mealAnchor: isEastward
            ? 'Breakfast at 06:30, Light dinner by 19:00'
            : 'Push meals 1 hour later',
        melatoninWindow: isEastward
            ? '20:30 (0.5mg optional)'
            : 'None recommended',
        isCompleted: true,
      ),
      CircadianShiftDay(
        dayOffset: -1,
        dayLabel: 'Pre-Departure Protocol 2 (Day -1)',
        targetBedtime: isEastward
            ? '20:30 (Home) - 90m Earlier'
            : '00:30 (Home) - 90m Later',
        targetWakeup: isEastward ? '05:00 (Home)' : '09:00 (Home)',
        lightExposureWindow: isEastward
            ? '05:30 - 08:30 (High-Intensity Light)'
            : '17:00 - 20:00 (Bright Light Exposure)',
        lightAvoidanceWindow: isEastward
            ? '18:30 - Bedtime (Darkness)'
            : '05:30 - 08:00 (Avoid Morning Light)',
        caffeineCutoff: isEastward ? '12:00 (Strict Zero Stimulants)' : '16:00',
        mealAnchor: isEastward
            ? 'Breakfast 05:30, Early fasting'
            : 'Late dinner at 20:30',
        melatoninWindow: isEastward ? '19:30 (0.5mg)' : 'None recommended',
        isCompleted: false,
      ),
      CircadianShiftDay(
        dayOffset: 0,
        dayLabel: 'Transit & Flight Day (Day 0)',
        targetBedtime: '22:00 (Destination Time)',
        targetWakeup: '06:30 (Destination Time)',
        lightExposureWindow:
            'Seek light during destination daytime; open cabin blinds',
        lightAvoidanceWindow:
            'Use eye mask & noise isolation during destination nighttime',
        caffeineCutoff: 'Zero caffeine during flight transit',
        mealAnchor: 'Eat in-flight only when destination is having meal times',
        melatoninWindow: '21:00 Dest Time (Take 30m before sleep)',
        isCompleted: false,
      ),
      CircadianShiftDay(
        dayOffset: 1,
        dayLabel: 'Destination Synchronization (Day +1)',
        targetBedtime: '22:30 (Local Destination Time)',
        targetWakeup: '07:00 (Local Destination Time)',
        lightExposureWindow: isEastward
            ? '07:30 - 11:00 (Outdoor Morning Light)'
            : '15:00 - 18:30 (Outdoor Afternoon Light)',
        lightAvoidanceWindow: isEastward
            ? '20:00 - Bedtime (Dim ambient room)'
            : '07:00 - 08:30 (Wear sunglasses)',
        caffeineCutoff: '14:00 (Hard stop)',
        mealAnchor: 'High-protein local breakfast at 07:30, dinner 19:30',
        melatoninWindow: '21:30 (Optional 1mg)',
        isCompleted: false,
      ),
      CircadianShiftDay(
        dayOffset: 2,
        dayLabel: 'Circadian Phase Lock (Day +2)',
        targetBedtime: '23:00 (Local Time)',
        targetWakeup: '07:00 (Local Time)',
        lightExposureWindow: '08:00 - 11:30 (Outdoor activity & daylight)',
        lightAvoidanceWindow: '21:00 - Bedtime (Screen dimming)',
        caffeineCutoff: '14:30',
        mealAnchor: 'Standard local schedule: Lunch 13:00, Dinner 20:00',
        melatoninWindow: '22:00 (If needed)',
        isCompleted: false,
      ),
    ];
  }

  JetlagPlan _generateDefaultPlan(String tripId) {
    return JetlagPlan(
      id: 'jetlag_$tripId',
      tripId: tripId,
      originCity: 'New York (JFK)',
      originTzOffset: -5,
      destinationCity: 'Islamabad (ISB)',
      destinationTzOffset: 5,
      departureTimestamp: DateTime.now().millisecondsSinceEpoch,
      arrivalTimestamp: DateTime.now()
          .add(const Duration(hours: 15))
          .millisecondsSinceEpoch,
      direction: 'Eastward',
      totalHourShift: 10,
      daysToAdapt: 7,
      shiftDays: _buildShiftDaysList(
        direction: 'Eastward',
        hourShift: 10,
        daysToAdapt: 7,
      ),
    );
  }

  String getOriginTimeString(DateTime now) {
    final plan = activePlan.value;
    final offset = plan?.originTzOffset ?? 0;
    final utc = now.toUtc();
    final originTime = utc.add(Duration(hours: offset));
    return _formatClockTime(originTime);
  }

  String getDestinationTimeString(DateTime now) {
    final plan = activePlan.value;
    final offset = plan?.destinationTzOffset ?? 0;
    final utc = now.toUtc();
    final destTime = utc.add(Duration(hours: offset));
    return _formatClockTime(destTime);
  }

  String _formatClockTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  double get adaptationPercentage {
    return activePlan.value?.completionRate ?? 0.0;
  }

  String get statusBadge {
    final rate = adaptationPercentage;
    if (rate >= 0.8) return 'CIRCADIAN SYNCHRONIZED';
    if (rate >= 0.4) return 'ADAPTING TO PACEMAKER';
    return 'PHASE SHIFT INITIATED';
  }
}

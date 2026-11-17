import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/domain/entities/circadian_protocol.dart';
import 'package:voyage_ai_app/domain/repositories/jetlag_repository.dart';
import 'package:voyage_ai_app/presentation/jetlag/controllers/jetlag_controller.dart';

class MockJetlagRepository implements JetlagRepository {
  JetlagPlan? plan = const JetlagPlan(
    id: 'jetlag_hunza_7d',
    tripId: 'trip_hunza_7d',
    originCity: 'New York (JFK)',
    originTzOffset: -5,
    destinationCity: 'Islamabad (ISB)',
    destinationTzOffset: 5,
    departureTimestamp: 1714521600000,
    arrivalTimestamp: 1714608000000,
    direction: 'Eastward',
    totalHourShift: 10,
    daysToAdapt: 7,
    shiftDays: [
      CircadianShiftDay(
        dayOffset: -2,
        dayLabel: 'Pre-Departure Protocol 1 (Day -2)',
        targetBedtime: '21:30',
        targetWakeup: '06:00',
        lightExposureWindow: '06:30 - 09:30',
        lightAvoidanceWindow: '19:30 - Bedtime',
        caffeineCutoff: '13:00',
        mealAnchor: 'Breakfast 06:30',
        melatoninWindow: '20:30',
        isCompleted: true,
      ),
      CircadianShiftDay(
        dayOffset: -1,
        dayLabel: 'Pre-Departure Protocol 2 (Day -1)',
        targetBedtime: '20:30',
        targetWakeup: '05:00',
        lightExposureWindow: '05:30 - 08:30',
        lightAvoidanceWindow: '18:30 - Bedtime',
        caffeineCutoff: '12:00',
        mealAnchor: 'Breakfast 05:30',
        melatoninWindow: '19:30',
        isCompleted: true,
      ),
      CircadianShiftDay(
        dayOffset: 0,
        dayLabel: 'Transit & Flight Day (Day 0)',
        targetBedtime: '22:00',
        targetWakeup: '06:30',
        lightExposureWindow: 'Cabin daylight',
        lightAvoidanceWindow: 'Eye mask',
        caffeineCutoff: 'Zero caffeine',
        mealAnchor: 'Sync with destination',
        melatoninWindow: '21:00',
        isCompleted: false,
      ),
      CircadianShiftDay(
        dayOffset: 1,
        dayLabel: 'Destination Sync (Day +1)',
        targetBedtime: '22:30',
        targetWakeup: '07:00',
        lightExposureWindow: '07:30 - 11:00',
        lightAvoidanceWindow: '20:00 - Bedtime',
        caffeineCutoff: '14:00',
        mealAnchor: 'Local breakfast',
        melatoninWindow: '21:30',
        isCompleted: false,
      ),
    ],
  );

  @override
  Future<JetlagPlan?> getPlanForTrip(String tripId) async => plan;

  @override
  Future<void> savePlan(JetlagPlan newPlan) async {
    plan = newPlan;
  }

  @override
  Future<void> toggleShiftDayCheckpoint(
    String planId,
    int dayOffset,
    bool isCompleted,
  ) async {
    if (plan != null) {
      final updatedDays = plan!.shiftDays.map((d) {
        if (d.dayOffset == dayOffset) {
          return d.copyWith(isCompleted: isCompleted);
        }
        return d;
      }).toList();
      plan = plan!.copyWith(shiftDays: updatedDays);
    }
  }

  @override
  Future<void> resetPlan(String planId) async {
    if (plan != null) {
      final updatedDays = plan!.shiftDays.map((d) {
        return d.copyWith(isCompleted: false);
      }).toList();
      plan = plan!.copyWith(shiftDays: updatedDays);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockJetlagRepository mockRepo;
  late JetlagController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockJetlagRepository();
    controller = JetlagController(mockRepo);
  });

  tearDown(() {
    Get.reset();
  });

  group('JetlagController Unit Tests', () {
    test(
      'Initial load retrieves circadian plan and computes metrics',
      () async {
        await controller.loadPlan('trip_hunza_7d');
        expect(controller.activePlan.value, isNotNull);
        expect(controller.activePlan.value!.originCity, 'New York (JFK)');
        expect(controller.activePlan.value!.destinationCity, 'Islamabad (ISB)');
        expect(controller.activePlan.value!.totalHourShift, 10);
        expect(controller.activePlan.value!.direction, 'Eastward');
        // 2 completed out of 4 days = 0.5 (50%)
        expect(controller.adaptationPercentage, 0.5);
        expect(controller.statusBadge, 'ADAPTING TO PACEMAKER');
      },
    );

    test('Toggles checkpoint and recalculates adaptation percentage', () async {
      await controller.loadPlan('trip_hunza_7d');

      // Toggle day 0 from false to true
      await controller.toggleCheckpoint(0);
      expect(controller.activePlan.value!.shiftDays[2].isCompleted, true);
      // 3 of 4 completed = 0.75
      expect(controller.adaptationPercentage, 0.75);

      // Toggle day 1 from false to true
      await controller.toggleCheckpoint(1);
      expect(controller.activePlan.value!.shiftDays[3].isCompleted, true);
      // 4 of 4 completed = 1.0
      expect(controller.adaptationPercentage, 1.0);
      expect(controller.statusBadge, 'CIRCADIAN SYNCHRONIZED');
    });

    test('Reset plan sets all daily shift checkpoints to incomplete', () async {
      await controller.loadPlan('trip_hunza_7d');
      expect(controller.adaptationPercentage, 0.5);

      await controller.resetPlan();
      expect(
        controller.activePlan.value!.shiftDays.every((d) => !d.isCompleted),
        true,
      );
      expect(controller.adaptationPercentage, 0.0);
      expect(controller.statusBadge, 'PHASE SHIFT INITIATED');
    });

    test('Generates custom plan for Eastward travel correctly', () async {
      await controller.generateCustomPlan(
        originCity: 'London (LHR)',
        originTzOffset: 0,
        destinationCity: 'Tokyo (HND)',
        destinationTzOffset: 9,
        departureDate: DateTime.now(),
      );

      final plan = controller.activePlan.value!;
      expect(plan.originCity, 'London (LHR)');
      expect(plan.destinationCity, 'Tokyo (HND)');
      expect(plan.totalHourShift, 9);
      expect(plan.direction, 'Eastward');
      expect(plan.shiftDays.isNotEmpty, true);
    });

    test('Generates custom plan for Westward travel correctly', () async {
      await controller.generateCustomPlan(
        originCity: 'Paris (CDG)',
        originTzOffset: 1,
        destinationCity: 'New York (JFK)',
        destinationTzOffset: -5,
        departureDate: DateTime.now(),
      );

      final plan = controller.activePlan.value!;
      expect(plan.originCity, 'Paris (CDG)');
      expect(plan.destinationCity, 'New York (JFK)');
      // -5 - 1 = -6 -> Westward 6h shift
      expect(plan.totalHourShift, 6);
      expect(plan.direction, 'Westward');
      expect(plan.shiftDays.isNotEmpty, true);
    });

    test('Formats origin and destination clock strings accurately', () async {
      await controller.loadPlan('trip_hunza_7d');
      final testTime = DateTime.utc(2026, 11, 17, 12, 0); // 12:00 UTC

      // Origin UTC-5 = 07:00
      final originStr = controller.getOriginTimeString(testTime);
      expect(originStr, '07:00');

      // Destination UTC+5 = 17:00
      final destStr = controller.getDestinationTimeString(testTime);
      expect(destStr, '17:00');
    });
  });
}

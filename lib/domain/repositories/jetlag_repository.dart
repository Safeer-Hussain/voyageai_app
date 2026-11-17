import '../entities/circadian_protocol.dart';

abstract class JetlagRepository {
  Future<JetlagPlan?> getPlanForTrip(String tripId);
  Future<void> savePlan(JetlagPlan plan);
  Future<void> toggleShiftDayCheckpoint(
    String planId,
    int dayOffset,
    bool isCompleted,
  );
  Future<void> resetPlan(String planId);
}

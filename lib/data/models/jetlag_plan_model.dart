import '../../domain/entities/circadian_protocol.dart';

class JetlagPlanModel extends JetlagPlan {
  const JetlagPlanModel({
    required super.id,
    required super.tripId,
    required super.originCity,
    required super.originTzOffset,
    required super.destinationCity,
    required super.destinationTzOffset,
    required super.departureTimestamp,
    required super.arrivalTimestamp,
    required super.direction,
    required super.totalHourShift,
    required super.daysToAdapt,
    required super.shiftDays,
  });

  factory JetlagPlanModel.fromEntity(JetlagPlan plan) {
    return JetlagPlanModel(
      id: plan.id,
      tripId: plan.tripId,
      originCity: plan.originCity,
      originTzOffset: plan.originTzOffset,
      destinationCity: plan.destinationCity,
      destinationTzOffset: plan.destinationTzOffset,
      departureTimestamp: plan.departureTimestamp,
      arrivalTimestamp: plan.arrivalTimestamp,
      direction: plan.direction,
      totalHourShift: plan.totalHourShift,
      daysToAdapt: plan.daysToAdapt,
      shiftDays: plan.shiftDays,
    );
  }

  factory JetlagPlanModel.fromMap(Map<String, dynamic> map) {
    final base = JetlagPlan.fromMap(map);
    return JetlagPlanModel.fromEntity(base);
  }
}

import '../../domain/entities/circadian_protocol.dart';
import '../../domain/repositories/jetlag_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/jetlag_plan_model.dart';

class JetlagRepositoryImpl implements JetlagRepository {
  final LocalStorageDatasource _datasource;

  JetlagRepositoryImpl(this._datasource);

  @override
  Future<JetlagPlan?> getPlanForTrip(String tripId) async {
    return await _datasource.getJetlagPlanForTrip(tripId);
  }

  @override
  Future<void> savePlan(JetlagPlan plan) async {
    final model = JetlagPlanModel.fromEntity(plan);
    await _datasource.insertJetlagPlan(model);
  }

  @override
  Future<void> toggleShiftDayCheckpoint(
    String planId,
    int dayOffset,
    bool isCompleted,
  ) async {
    await _datasource.updateJetlagShiftDayCheckpoint(
      planId,
      dayOffset,
      isCompleted,
    );
  }

  @override
  Future<void> resetPlan(String planId) async {
    await _datasource.resetJetlagPlan(planId);
  }
}

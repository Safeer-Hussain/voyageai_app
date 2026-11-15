import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.tripId,
    required super.dayNumber,
    required super.timeSlot,
    required super.title,
    required super.description,
    required super.category,
    required super.costUsd,
    required super.isCompleted,
    required super.latitude,
    required super.longitude,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      dayNumber: (map['day_number'] as num).toInt(),
      timeSlot: map['time_slot'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      costUsd: (map['cost_usd'] as num).toDouble(),
      isCompleted: (map['is_completed'] as num).toInt() == 1,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'day_number': dayNumber,
      'time_slot': timeSlot,
      'title': title,
      'description': description,
      'category': category,
      'cost_usd': costUsd,
      'is_completed': isCompleted ? 1 : 0,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ActivityModel.fromEntity(Activity activity) {
    return ActivityModel(
      id: activity.id,
      tripId: activity.tripId,
      dayNumber: activity.dayNumber,
      timeSlot: activity.timeSlot,
      title: activity.title,
      description: activity.description,
      category: activity.category,
      costUsd: activity.costUsd,
      isCompleted: activity.isCompleted,
      latitude: activity.latitude,
      longitude: activity.longitude,
    );
  }
}

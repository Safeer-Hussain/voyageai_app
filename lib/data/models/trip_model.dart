import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.title,
    required super.destination,
    required super.durationDays,
    required super.pace,
    required super.budgetTier,
    required super.totalBudgetUsd,
    required super.imageAsset,
    required super.createdAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      durationDays: (map['duration_days'] as num).toInt(),
      pace: map['pace'] as String,
      budgetTier: map['budget_tier'] as String,
      totalBudgetUsd: (map['total_budget_usd'] as num).toDouble(),
      imageAsset: map['image_asset'] as String,
      createdAt: (map['created_at'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'duration_days': durationDays,
      'pace': pace,
      'budget_tier': budgetTier,
      'total_budget_usd': totalBudgetUsd,
      'image_asset': imageAsset,
      'created_at': createdAt,
    };
  }

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      title: trip.title,
      destination: trip.destination,
      durationDays: trip.durationDays,
      pace: trip.pace,
      budgetTier: trip.budgetTier,
      totalBudgetUsd: trip.totalBudgetUsd,
      imageAsset: trip.imageAsset,
      createdAt: trip.createdAt,
    );
  }
}

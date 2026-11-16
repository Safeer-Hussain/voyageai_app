import '../../domain/entities/packing_item.dart';

class PackingItemModel extends PackingItem {
  const PackingItemModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.category,
    required super.weightKg,
    required super.isPacked,
    required super.isEssential,
  });

  factory PackingItemModel.fromMap(Map<String, dynamic> map) {
    return PackingItemModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      weightKg: (map['weight_kg'] as num).toDouble(),
      isPacked: (map['is_packed'] as num).toInt() == 1,
      isEssential: (map['is_essential'] as num).toInt() == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'title': title,
      'category': category,
      'weight_kg': weightKg,
      'is_packed': isPacked ? 1 : 0,
      'is_essential': isEssential ? 1 : 0,
    };
  }

  factory PackingItemModel.fromEntity(PackingItem item) {
    return PackingItemModel(
      id: item.id,
      tripId: item.tripId,
      title: item.title,
      category: item.category,
      weightKg: item.weightKg,
      isPacked: item.isPacked,
      isEssential: item.isEssential,
    );
  }
}

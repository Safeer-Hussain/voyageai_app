class Activity {
  final String id;
  final String tripId;
  final int dayNumber;
  final String timeSlot;
  final String title;
  final String description;
  final String category;
  final double costUsd;
  final bool isCompleted;
  final double latitude;
  final double longitude;

  const Activity({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.timeSlot,
    required this.title,
    required this.description,
    required this.category,
    required this.costUsd,
    required this.isCompleted,
    required this.latitude,
    required this.longitude,
  });

  Activity copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    String? timeSlot,
    String? title,
    String? description,
    String? category,
    double? costUsd,
    bool? isCompleted,
    double? latitude,
    double? longitude,
  }) {
    return Activity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      timeSlot: timeSlot ?? this.timeSlot,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      costUsd: costUsd ?? this.costUsd,
      isCompleted: isCompleted ?? this.isCompleted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

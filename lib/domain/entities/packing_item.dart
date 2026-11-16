class PackingItem {
  final String id;
  final String tripId;
  final String title;
  final String
  category; // Technical Gear, Thermal Apparel, Medical, Electronics, Documents
  final double weightKg;
  final bool isPacked;
  final bool isEssential;

  const PackingItem({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.weightKg,
    required this.isPacked,
    required this.isEssential,
  });

  PackingItem copyWith({
    String? id,
    String? tripId,
    String? title,
    String? category,
    double? weightKg,
    bool? isPacked,
    bool? isEssential,
  }) {
    return PackingItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      isPacked: isPacked ?? this.isPacked,
      isEssential: isEssential ?? this.isEssential,
    );
  }
}

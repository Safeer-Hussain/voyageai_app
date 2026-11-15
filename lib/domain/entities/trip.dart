class Trip {
  final String id;
  final String title;
  final String destination;
  final int durationDays;
  final String pace;
  final String budgetTier;
  final double totalBudgetUsd;
  final String imageAsset;
  final int createdAt;

  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.durationDays,
    required this.pace,
    required this.budgetTier,
    required this.totalBudgetUsd,
    required this.imageAsset,
    required this.createdAt,
  });

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    int? durationDays,
    String? pace,
    String? budgetTier,
    double? totalBudgetUsd,
    String? imageAsset,
    int? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      durationDays: durationDays ?? this.durationDays,
      pace: pace ?? this.pace,
      budgetTier: budgetTier ?? this.budgetTier,
      totalBudgetUsd: totalBudgetUsd ?? this.totalBudgetUsd,
      imageAsset: imageAsset ?? this.imageAsset,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

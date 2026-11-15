class Expense {
  final String id;
  final String tripId;
  final String title;
  final String category;
  final double originalAmount;
  final String currencyCode;
  final double amountUsd;
  final int splitCount;
  final int timestamp;

  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.originalAmount,
    required this.currencyCode,
    required this.amountUsd,
    required this.splitCount,
    required this.timestamp,
  });

  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    String? category,
    double? originalAmount,
    String? currencyCode,
    double? amountUsd,
    int? splitCount,
    int? timestamp,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      category: category ?? this.category,
      originalAmount: originalAmount ?? this.originalAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      amountUsd: amountUsd ?? this.amountUsd,
      splitCount: splitCount ?? this.splitCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

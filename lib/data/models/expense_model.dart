import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.category,
    required super.originalAmount,
    required super.currencyCode,
    required super.amountUsd,
    required super.splitCount,
    required super.timestamp,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      originalAmount: (map['original_amount'] as num).toDouble(),
      currencyCode: map['currency_code'] as String,
      amountUsd: (map['amount_usd'] as num).toDouble(),
      splitCount: (map['split_count'] as num).toInt(),
      timestamp: (map['timestamp'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'title': title,
      'category': category,
      'original_amount': originalAmount,
      'currency_code': currencyCode,
      'amount_usd': amountUsd,
      'split_count': splitCount,
      'timestamp': timestamp,
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      title: expense.title,
      category: expense.category,
      originalAmount: expense.originalAmount,
      currencyCode: expense.currencyCode,
      amountUsd: expense.amountUsd,
      splitCount: expense.splitCount,
      timestamp: expense.timestamp,
    );
  }
}

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/trip.dart';
import '../../../domain/repositories/expense_repository.dart';

class ExpenseLedgerController extends GetxController {
  final ExpenseRepository _repository;
  final SharedPreferences _prefs;

  ExpenseLedgerController(this._repository, this._prefs);

  final RxList<Expense> expenses = <Expense>[].obs;
  final RxString selectedCurrency = 'USD'.obs;
  final Rxn<Trip> activeTrip = Rxn<Trip>();
  final RxBool isLoading = false.obs;

  static const List<String> categories = [
    'Flights',
    'Stays',
    'Food',
    'Transport',
    'Gear',
  ];

  @override
  void onInit() {
    super.onInit();
    final savedCurrency = _prefs.getString(AppConstants.keyBaseCurrency);
    if (savedCurrency != null &&
        AppConstants.supportedCurrencies.contains(savedCurrency)) {
      selectedCurrency.value = savedCurrency;
    }
  }

  void setActiveTrip(Trip trip) {
    activeTrip.value = trip;
    loadExpenses(trip.id);
  }

  Future<void> loadExpenses(String tripId) async {
    isLoading.value = true;
    try {
      final loaded = await _repository.getExpensesForTrip(tripId);
      expenses.assignAll(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  void setCurrency(String code) {
    selectedCurrency.value = code;
    _prefs.setString(AppConstants.keyBaseCurrency, code);
  }

  double get totalBudgetSelectedCurrency {
    final budgetUsd = activeTrip.value?.totalBudgetUsd ?? 2850.0;
    return CurrencyFormatter.convert(
      amount: budgetUsd,
      fromCurrency: 'USD',
      toCurrency: selectedCurrency.value,
    );
  }

  double get totalSpentSelectedCurrency {
    final totalSpentUsd = expenses.fold<double>(
      0.0,
      (sum, e) => sum + e.amountUsd,
    );
    return CurrencyFormatter.convert(
      amount: totalSpentUsd,
      fromCurrency: 'USD',
      toCurrency: selectedCurrency.value,
    );
  }

  double get remainingBudgetSelectedCurrency {
    return totalBudgetSelectedCurrency - totalSpentSelectedCurrency;
  }

  double get dailyAllowanceSelectedCurrency {
    final days = activeTrip.value?.durationDays ?? 7;
    return remainingBudgetSelectedCurrency / (days > 0 ? days : 1);
  }

  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {
      'Flights': 0.0,
      'Stays': 0.0,
      'Food': 0.0,
      'Transport': 0.0,
      'Gear': 0.0,
    };

    for (final exp in expenses) {
      final amountInSelected = CurrencyFormatter.convert(
        amount: exp.amountUsd,
        fromCurrency: 'USD',
        toCurrency: selectedCurrency.value,
      );
      breakdown[exp.category] =
          (breakdown[exp.category] ?? 0.0) + amountInSelected;
    }
    return breakdown;
  }

  Future<bool> addExpense({
    required String tripId,
    required String title,
    required String category,
    required double originalAmount,
    required String originalCurrency,
    required int splitCount,
  }) async {
    final amountUsd = CurrencyFormatter.convert(
      amount: originalAmount,
      fromCurrency: originalCurrency,
      toCurrency: 'USD',
    );

    final newExpense = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      tripId: tripId,
      title: title,
      category: category,
      originalAmount: originalAmount,
      currencyCode: originalCurrency,
      amountUsd: amountUsd,
      splitCount: splitCount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    expenses.insert(0, newExpense);
    expenses.refresh();
    await _repository.addExpense(newExpense);

    final shareText = splitCount > 1
        ? ' (Split between $splitCount travelers)'
        : '';
    AppFeedback.showSuccess(
      title: 'Expense Logged',
      message:
          '$title of ${CurrencyFormatter.format(originalAmount, originalCurrency)}$shareText added.',
    );
    return true;
  }

  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
    expenses.refresh();
    await _repository.deleteExpense(id);
    AppFeedback.showInfo(
      title: 'Expense Removed',
      message: 'Item has been deleted from the ledger.',
    );
  }
}

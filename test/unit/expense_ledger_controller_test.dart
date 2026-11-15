import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyage_ai_app/domain/entities/expense.dart';
import 'package:voyage_ai_app/domain/entities/trip.dart';
import 'package:voyage_ai_app/domain/repositories/expense_repository.dart';
import 'package:voyage_ai_app/presentation/expense_ledger/controllers/expense_ledger_controller.dart';

class MockExpenseRepository implements ExpenseRepository {
  List<Expense> expenses = [
    const Expense(
      id: 'exp_1',
      tripId: 'trip_hunza_7d',
      title: 'Mountain Jeep Charter',
      category: 'Transport',
      originalAmount: 100.0,
      currencyCode: 'USD',
      amountUsd: 100.0,
      splitCount: 2,
      timestamp: 1000,
    ),
    const Expense(
      id: 'exp_2',
      tripId: 'trip_hunza_7d',
      title: 'Baltit Organic Feast',
      category: 'Food',
      originalAmount: 50.0,
      currencyCode: 'USD',
      amountUsd: 50.0,
      splitCount: 1,
      timestamp: 2000,
    ),
  ];

  @override
  Future<List<Expense>> getExpensesForTrip(String tripId) async =>
      expenses.where((e) => e.tripId == tripId).toList();

  @override
  Future<void> addExpense(Expense expense) async => expenses.insert(0, expense);

  @override
  Future<void> deleteExpense(String expenseId) async =>
      expenses.removeWhere((e) => e.id == expenseId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExpenseRepository mockRepo;
  late SharedPreferences prefs;
  late ExpenseLedgerController controller;

  const sampleTrip = Trip(
    id: 'trip_hunza_7d',
    title: 'Hunza Trip',
    destination: 'Hunza',
    durationDays: 5,
    pace: 'Balanced',
    budgetTier: 'Expedition',
    totalBudgetUsd: 1000.0,
    imageAsset: 'assets/images/karakoram_hunza.png',
    createdAt: 1000,
  );

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockRepo = MockExpenseRepository();
    controller = ExpenseLedgerController(mockRepo, prefs);
    controller.setActiveTrip(sampleTrip);
    await controller.loadExpenses(sampleTrip.id);
  });

  group('ExpenseLedgerController Unit Tests', () {
    test('Calculates total budget, total spent and remaining in USD', () {
      expect(controller.totalBudgetSelectedCurrency, 1000.0);
      expect(controller.totalSpentSelectedCurrency, 150.0);
      expect(controller.remainingBudgetSelectedCurrency, 850.0);
      expect(controller.dailyAllowanceSelectedCurrency, 850.0 / 5);
    });

    test(
      'Converts budget and spending accurately when switching currency to PKR',
      () {
        controller.setCurrency('PKR');
        expect(controller.selectedCurrency.value, 'PKR');
        expect(controller.totalBudgetSelectedCurrency, 1000.0 * 278.50);
        expect(controller.totalSpentSelectedCurrency, 150.0 * 278.50);
        expect(controller.remainingBudgetSelectedCurrency, 850.0 * 278.50);
      },
    );

    test(
      'addExpense converts foreign currency to USD base and updates ledger',
      () async {
        await controller.addExpense(
          tripId: 'trip_hunza_7d',
          title: 'Local Craft Gift',
          category: 'Gear',
          originalAmount: 27850.0, // Equals 100 USD
          originalCurrency: 'PKR',
          splitCount: 1,
        );

        expect(controller.expenses.length, 3);
        expect(controller.expenses.first.title, 'Local Craft Gift');
        expect(controller.expenses.first.amountUsd, closeTo(100.0, 0.01));
        expect(controller.totalSpentSelectedCurrency, 250.0);
      },
    );

    test(
      'deleteExpense removes item and recalculates ledger balance',
      () async {
        await controller.deleteExpense('exp_1');
        expect(controller.expenses.length, 1);
        expect(controller.totalSpentSelectedCurrency, 50.0);
        expect(controller.remainingBudgetSelectedCurrency, 950.0);
      },
    );
  });
}

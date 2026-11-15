import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpensesForTrip(String tripId);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
}

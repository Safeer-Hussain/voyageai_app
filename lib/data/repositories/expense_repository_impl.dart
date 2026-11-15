import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalStorageDatasource _datasource;

  ExpenseRepositoryImpl(this._datasource);

  @override
  Future<List<Expense>> getExpensesForTrip(String tripId) async {
    return await _datasource.getExpensesForTrip(tripId);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _datasource.insertExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _datasource.deleteExpense(expenseId);
  }
}

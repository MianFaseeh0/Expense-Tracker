import '../models/expense_category.dart';
import '../models/expense_model.dart';

/// Abstraction over expense persistence so controllers depend on this
/// contract rather than on Firestore directly (Dependency Inversion,
/// Open/Closed — a new backend is a new implementation, not a rewrite of
/// every screen that reads/writes expenses).
abstract interface class ExpenseRepository {
  /// Live stream of every expense belonging to [ownerUid].
  Stream<List<ExpenseModel>> watchExpenses(String ownerUid);

  /// Live stream of expenses belonging to [ownerUid], scoped to [category].
  Stream<List<ExpenseModel>> watchExpensesByCategory(
    String ownerUid,
    ExpenseCategory category,
  );

  Future<void> addExpense(ExpenseModel expense, {required String ownerUid});

  /// Deletes the expense identified by [expenseId] and returns its raw
  /// stored payload, so the caller can offer an "Undo" that restores it
  /// via [restoreExpense].
  Future<Map<String, dynamic>> deleteExpense(String expenseId);

  Future<void> restoreExpense(String expenseId, Map<String, dynamic> data);
}

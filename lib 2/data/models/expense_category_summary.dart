import 'expense_category.dart';
import 'expense_model.dart';

/// Aggregates every [ExpenseModel] belonging to a single [ExpenseCategory].
///
/// Renamed from `ExpenseBucket` to make explicit that this is a derived
/// summary, not a storage bucket.
class ExpenseCategorySummary {
  const ExpenseCategorySummary({
    required this.category,
    required this.expenses,
  });

  factory ExpenseCategorySummary.from(
    List<ExpenseModel> allExpenses,
    ExpenseCategory category,
  ) {
    return ExpenseCategorySummary(
      category: category,
      expenses: allExpenses
          .where((expense) => expense.category == category)
          .toList(),
    );
  }

  final ExpenseCategory category;
  final List<ExpenseModel> expenses;

  double get totalAmount =>
      expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
}

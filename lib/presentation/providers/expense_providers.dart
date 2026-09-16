import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import 'repository_providers.dart';
import 'session_providers.dart';

/// Live stream of every expense owned by the current user. Emits an empty
/// stream (instead of throwing) when nobody is signed in yet.
final expensesStreamProvider = StreamProvider.autoDispose<List<ExpenseModel>>(
  (ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    if (uid == null) return const Stream<List<ExpenseModel>>.empty();
    return ref.watch(expenseRepositoryProvider).watchExpenses(uid);
  },
);

/// Live stream of expenses scoped to a single [ExpenseCategory], used by
/// the category-detail screen.
final categoryExpensesStreamProvider = StreamProvider.autoDispose
    .family<List<ExpenseModel>, ExpenseCategory>((ref, category) {
      final uid = ref.watch(currentUserProvider)?.uid;
      if (uid == null) return const Stream<List<ExpenseModel>>.empty();
      return ref
          .watch(expenseRepositoryProvider)
          .watchExpensesByCategory(uid, category);
    });

/// Feature: free-text search over the expense list. Holding this as its
/// own provider keeps the filtering logic reactive and out of widget state.
final expenseSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Applies [expenseSearchQueryProvider] to [expensesStreamProvider],
/// matching case-insensitively against the expense name.
final filteredExpensesProvider = Provider.autoDispose<AsyncValue<List<ExpenseModel>>>(
  (ref) {
    final query = ref.watch(expenseSearchQueryProvider).trim().toLowerCase();
    final expensesAsync = ref.watch(expensesStreamProvider);

    if (query.isEmpty) return expensesAsync;

    return expensesAsync.whenData(
      (expenses) => expenses
          .where((expense) => expense.name.toLowerCase().contains(query))
          .toList(),
    );
  },
);

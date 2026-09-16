import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/expense_category.dart';
import '../../data/models/expense_model.dart';
import 'repository_providers.dart';
import 'session_providers.dart';

final expensesStreamProvider = StreamProvider.autoDispose<List<ExpenseModel>>(
  (ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    if (uid == null) return const Stream<List<ExpenseModel>>.empty();
    return ref.watch(expenseRepositoryProvider).watchExpenses(uid);
  },
);

final categoryExpensesStreamProvider = StreamProvider.autoDispose
    .family<List<ExpenseModel>, ExpenseCategory>((ref, category) {
      final uid = ref.watch(currentUserProvider)?.uid;
      if (uid == null) return const Stream<List<ExpenseModel>>.empty();
      return ref
          .watch(expenseRepositoryProvider)
          .watchExpensesByCategory(uid, category);
    });

final expenseSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

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

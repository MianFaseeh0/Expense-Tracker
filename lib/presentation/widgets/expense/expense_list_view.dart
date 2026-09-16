import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expense_providers.dart';
import 'expense_list_body.dart';

/// The "Expenses" tab: a search field over the user's full expense list.
///
/// Adds a search-as-you-type filter (new feature) that the original
/// `ExpensesList` widget didn't have — previously the only way to find a
/// specific expense was to scroll through the entire list.
class ExpenseListView extends ConsumerWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search expenses…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) =>
                ref.read(expenseSearchQueryProvider.notifier).state = value,
          ),
        ),
         ExpenseListBody(
            expensesAsync: filteredExpenses,
            emptyMessage:
                ref.watch(expenseSearchQueryProvider).trim().isEmpty
                ? 'Oh no! No expenses here — try adding some.'
                : 'No expenses match your search.',
          ),
        
      ],
    );
  }
}

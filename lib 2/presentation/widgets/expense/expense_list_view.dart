import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expense_providers.dart';
import 'expense_list_body.dart';

class ExpenseListView extends ConsumerWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);

    return Column(
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
        Expanded(
          child: ExpenseListBody(
            expensesAsync: filteredExpenses,
            emptyMessage:
                ref.watch(expenseSearchQueryProvider).trim().isEmpty
                ? 'Oh no! No expenses here — try adding some.'
                : 'No expenses match your search.',
          ),
        ),
      ],
    );
  }
}

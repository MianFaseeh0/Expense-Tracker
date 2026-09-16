import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/expense_category.dart';
import '../../providers/expense_providers.dart';
import '../../widgets/expense/expense_list_body.dart';

/// Shows every expense within a single [ExpenseCategory].
///
/// Rebuilt from `CatItemScreen`, which previously ran its own raw
/// Firestore `StreamBuilder` query and duplicated the list-item markup
/// from `widgets/expenses_list.dart` nearly verbatim. It now reuses
/// [categoryExpensesStreamProvider] and the shared [ExpenseListBody].
class CategoryExpensesScreen extends ConsumerWidget {
  const CategoryExpensesScreen({required this.category, super.key});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(
      categoryExpensesStreamProvider(category),
    );

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: ExpenseListBody(
        expensesAsync: expensesAsync,
        emptyMessage: 'Oh no! No expenses here — try adding some.',
      ),
    );
  }
}

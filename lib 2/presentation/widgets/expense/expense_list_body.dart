import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/expense_model.dart';
import '../../providers/expense_controller.dart';
import '../../providers/repository_providers.dart';
import 'expense_list_tile.dart';

class ExpenseListBody extends ConsumerWidget {
  const ExpenseListBody({
    required this.expensesAsync,
    this.emptyMessage = 'Oh no! No expenses here — try adding some.',
    super.key,
  });

  final AsyncValue<List<ExpenseModel>> expensesAsync;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load expenses.',
          style: GoogleFonts.spaceMono(fontSize: 15),
        ),
      ),
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(fontSize: 15),
            ),
          );
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ExpenseListTile(
              expense: expense,
              onDelete: () => _deleteWithUndo(context, ref, expense),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final controller = ref.read(expenseControllerProvider);
    final errorHandler = ref.read(errorHandlerServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final deletedData = await controller.deleteExpense(expense.id);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Expense deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => errorHandler.guard(
              () => controller.restoreExpense(expense.id, deletedData),
            ),
          ),
        ),
      );
    } catch (error) {
      errorHandler.handle(error);
    }
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_category_summary.dart';
import '../../../data/models/expense_model.dart';
import '../../providers/expense_providers.dart';
import 'expense_category_bar.dart';

/// A frosted-glass bar chart showing spend per [ExpenseCategory].
///
/// The original `Chart` widget opened its own Firestore query directly
/// inside a `StatefulWidget`, duplicating the exact query already used by
/// the expense list. This version reads from the shared
/// [expensesStreamProvider] instead, so there's a single live query for the
/// whole screen rather than one per widget.
class ExpenseSummaryChart extends ConsumerWidget {
  const ExpenseSummaryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(60, 118, 118, 118).withValues(
              alpha: .25,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: expensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Could not load chart',
                style: GoogleFonts.spaceMono(fontSize: 13),
              ),
            ),
            data: (expenses) => _ChartBody(expenses: expenses),
          ),
        ),
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody({required this.expenses});

  final List<ExpenseModel> expenses;

  @override
  Widget build(BuildContext context) {
    final summaries = ExpenseCategory.values
        .map(
          (category) => ExpenseCategorySummary.from(expenses, category),
        )
        .toList();

    final maxTotal = summaries.fold<double>(
      0,
      (max, summary) =>
          summary.totalAmount > max ? summary.totalAmount : max,
    );

    if (maxTotal == 0) {
      return Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              'Empty',
              style: GoogleFonts.spaceMono(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _CategoryIconRow(summaries: summaries),
        ],
      );
    }

    return Column(
      children: [
        const Spacer(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final summary in summaries)
                ExpenseCategoryBar(
                  fillFraction: summary.totalAmount == 0
                      ? 0
                      : summary.totalAmount / maxTotal,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _CategoryIconRow(summaries: summaries),
      ],
    );
  }
}

class _CategoryIconRow extends StatelessWidget {
  const _CategoryIconRow({required this.summaries});

  final List<ExpenseCategorySummary> summaries;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: summaries
          .map(
            (summary) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(expenseCategoryIcons[summary.category]),
              ),
            ),
          )
          .toList(),
    );
  }
}

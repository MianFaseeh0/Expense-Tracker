import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/expense_model.dart';
import '../../providers/expense_providers.dart';

/// New feature: an at-a-glance spending summary (all-time total and this
/// calendar month's total), shown above the category chart on the home
/// screen. The original app had no aggregate spend indicator anywhere —
/// the closest thing was the per-category bar chart.
class SpendingOverviewCard extends ConsumerWidget {
  const SpendingOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);

    return expensesAsync.maybeWhen(
      data: (expenses) => _buildCard(context, expenses),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final totalSpend = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final thisMonthSpend = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryColumn(
              label: 'This Month',
              amount: thisMonthSpend,
            ),
          ),
          Container(width: 1, height: 34, color: Colors.white24),
          Expanded(
            child: _SummaryColumn(label: 'All Time', amount: totalSpend),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: GoogleFonts.spaceMono(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

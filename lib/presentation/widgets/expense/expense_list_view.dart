import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expense_providers.dart';
import '../charts/expense_summary_chart.dart';
import 'expense_list_body.dart';

/// The Expenses tab: chart on top, search bar below it, then the
/// list. As the list is scrolled, the chart shrinks and fades away;
/// the search bar stays pinned right where the chart used to end, and
/// the list keeps filling the screen underneath it.
class ExpenseListView extends ConsumerWidget {
  const ExpenseListView({super.key});

  static const double _graphHeight = 190.0;
  static const double _searchBarHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final emptyMessage = ref.watch(expenseSearchQueryProvider).trim().isEmpty
        ? 'Oh no! No expenses here — try adding some.'
        : 'No expenses match your search.';

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: false,
          delegate: _CollapsingGraphDelegate(maxHeight: _graphHeight),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchBarDelegate(height: _searchBarHeight),
        ),
        ExpenseListBody(
          expensesAsync: filteredExpenses,
          emptyMessage: emptyMessage,
        ),
      ],
    );
  }
}

/// The chart. Shrinks from [maxHeight] down to 0 and fades out as the
/// list is scrolled.
class _CollapsingGraphDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingGraphDelegate({required this.maxHeight});

  final double maxHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / maxHeight).clamp(0.0, 1.0);

    return ClipRect(
      child: Opacity(
        opacity: 1.0 - progress,
        child: OverflowBox(
          minHeight: 0,
          maxHeight: maxHeight,
          alignment: Alignment.topCenter,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpenseSummaryChart(),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsingGraphDelegate oldDelegate) {
    return oldDelegate.maxHeight != maxHeight;
  }
}

/// The search bar. Sits right below the chart, and stays pinned in
/// place once the chart has fully collapsed.
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  _SearchBarDelegate({required this.height});

  final double height;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Consumer(
      builder: (context, ref, _) {
        return Material(
          color: Colors.transparent,
          child: Padding(
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
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}
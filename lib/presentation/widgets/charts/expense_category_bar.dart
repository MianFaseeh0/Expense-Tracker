import 'package:flutter/material.dart';

/// A single proportional bar within [ExpenseSummaryChart].
///
/// Renamed from `ChartBar` to `ExpenseCategoryBar` to say what it
/// represents rather than just what it looks like.
class ExpenseCategoryBar extends StatelessWidget {
  const ExpenseCategoryBar({required this.fillFraction, super.key});

  /// How full the bar should be, `0.0`-`1.0`.
  final double fillFraction;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FractionallySizedBox(
          heightFactor: fillFraction,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              color: const Color.fromARGB(160, 0, 0, 0),
            ),
          ),
        ),
      ),
    );
  }
}

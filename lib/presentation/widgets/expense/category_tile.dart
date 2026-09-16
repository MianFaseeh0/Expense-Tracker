import 'package:flutter/material.dart';

import '../../../data/models/expense_category.dart';
import '../../views/home/category_expenses_screen.dart';

/// A tappable tile representing one [ExpenseCategory] in the categories
/// grid. Renamed from `CategoryOverlay` — it isn't an overlay, it's a grid
/// tile that navigates to that category's expense list.
class CategoryTile extends StatelessWidget {
  const CategoryTile({required this.category, super.key});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryExpensesScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(expenseCategoryIcons[category], color: Colors.white),
            Text(
              category.name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

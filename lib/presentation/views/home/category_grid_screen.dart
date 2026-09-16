import 'package:flutter/material.dart';
import '../../../data/models/expense_category.dart';
import '../../widgets/expense/category_tile.dart';

class CategoryGridScreen extends StatelessWidget {
  const CategoryGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: ExpenseCategory.values.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
      ),
      itemBuilder: (context, index) {
        return CategoryTile(category: ExpenseCategory.values[index]);
      },
    );
  }
}
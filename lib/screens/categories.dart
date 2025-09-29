import 'package:expensetracker/model/data.dart';
import 'package:expensetracker/widgets/category_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: CategoryIcons.length,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
      ),
      itemBuilder: (context, index) {
        return CategoryOverlay(
          icon: CategoryIcons[Catogary.values[index]]!,
          catname: Catogary.values[index].name.toString(),
        );
      },
    );
  }
}

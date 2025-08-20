import 'dart:ui';

import 'package:expensetracker/screens/cat_item.dart';
import 'package:flutter/material.dart';

class CategoryOverlay extends StatelessWidget {
  const CategoryOverlay({required this.catname, required this.icon, super.key});
  final String catname;
  final IconData icon;
  @override
  Widget build(context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => CatItemScreen(catname: catname)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            Text(
              catname,
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

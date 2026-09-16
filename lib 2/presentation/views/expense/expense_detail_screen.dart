import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';

/// Read-only detail view for a single [ExpenseModel].
///
/// Previously took four loose, unrelated parameters (`image`, `title`,
/// `cat`, `detail`) that callers had to remember to keep in sync. Taking
/// the whole [ExpenseModel] instead removes that duplication and any risk
/// of the fields drifting apart.
class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({required this.expense, super.key});

  final ExpenseModel expense;

  @override
  Widget build(BuildContext context) {
    final imageFile = expense.imagePath != null
        ? File(expense.imagePath!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Detail',
          style: GoogleFonts.spaceMono(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Hero(
                tag: 'expense-image-${expense.id}',
                child: imageFile != null
                    ? Image.file(imageFile, fit: BoxFit.cover)
                    : const Center(child: Text('No Image Added')),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  expense.name,
                  style: GoogleFonts.spaceMono(fontSize: 22),
                ),
                const Spacer(),
                Icon(expenseCategoryIcons[expense.category], size: 30),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              expense.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

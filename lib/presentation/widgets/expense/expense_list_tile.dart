import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../views/expense/expense_detail_screen.dart';

/// A single expense entry: thumbnail, name, amount, category icon and date.
///
/// Extracted from the old `ExpensesList`'s `itemBuilder`, which built this
/// entire card inline — pulling it out lets it be reused from both the
/// full expense list and the category-scoped expense list, which
/// previously duplicated this markup nearly verbatim.
class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    required this.expense,
    required this.onDelete,
    super.key,
  });

  final ExpenseModel expense;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageFile = expense.imagePath != null
        ? File(expense.imagePath!)
        : null;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expense: expense),
          ),
        );
      },
      onLongPress: () => _confirmDelete(context),
      child: Card(
        color: Colors.black,
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(60, 118, 118, 118).withValues(
                    alpha: 0.25,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.hardEdge,
                child: Hero(
                  tag: 'expense-image-${expense.id}',
                  child: _ExpenseThumbnail(imageFile: imageFile),
                ),
              ),
              Text(
                expense.name,
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceMono(color: Colors.white),
                  ),
                  const Spacer(),
                  Icon(
                    expenseCategoryIcons[expense.category],
                    color: Colors.white,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    expense.formattedDate,
                    style: GoogleFonts.spaceMono(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ExpenseThumbnail extends StatelessWidget {
  const _ExpenseThumbnail({required this.imageFile});

  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) return _placeholderIcon();

    return FutureBuilder<bool>(
      future: imageFile!.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == true) {
          return Image.file(imageFile!, fit: BoxFit.cover);
        }
        return _placeholderIcon();
      },
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: Colors.grey,
      child: const Icon(
        Icons.receipt_long,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// The set of buckets an [ExpenseModel] can be classified under.
///
/// Renamed from the original `Catogary` (typo) to `ExpenseCategory` for
/// clarity and correctness; `name` is still what gets persisted to
/// Firestore, so existing documents remain readable.
enum ExpenseCategory { food, extras, leisure, work, household, personal }

/// Icon lookup for each [ExpenseCategory], kept next to the enum so the two
/// can never drift out of sync.
const Map<ExpenseCategory, IconData> expenseCategoryIcons = {
  ExpenseCategory.food: Icons.lunch_dining,
  ExpenseCategory.extras: Icons.yard_rounded,
  ExpenseCategory.work: Icons.work_sharp,
  ExpenseCategory.leisure: Icons.chair,
  ExpenseCategory.household: Icons.house,
  ExpenseCategory.personal: Icons.emoji_symbols_outlined,
};

/// Resolves a persisted category string (Firestore `category` field) back
/// into an [ExpenseCategory], falling back to [ExpenseCategory.extras] for
/// unrecognized/legacy values.
ExpenseCategory expenseCategoryFromName(String? name) {
  return ExpenseCategory.values.firstWhere(
    (category) => category.name == name,
    orElse: () => ExpenseCategory.extras,
  );
}

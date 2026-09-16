import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/utils/date_formatting.dart';
import 'expense_category.dart';

/// Immutable domain model for a single expense entry.
///
/// The original `Expense` class mistakenly typed its image field as
/// `Text?` (a widget, not a file reference) and had no notion of a
/// Firestore document id, which made updates/deletes awkward. This version
/// fixes both and owns its own (de)serialization so no other layer needs
/// to know Firestore's field names.
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    this.description = '',
    this.imagePath,
  });

  /// Firestore document id. Empty for a draft that hasn't been saved yet.
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String description;
  final String? imagePath;

  String get formattedDate => DateFormatting.formatShort(date);

  factory ExpenseModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final timestamp = data[FirestorePaths.fieldDate];
    final date = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();

    return ExpenseModel(
      id: id,
      name: (data[FirestorePaths.fieldName] as String?) ?? 'Untitled',
      amount: (data[FirestorePaths.fieldAmount] as num?)?.toDouble() ?? 0,
      date: date,
      category: expenseCategoryFromName(
        data[FirestorePaths.fieldCategory] as String?,
      ),
      description: (data[FirestorePaths.fieldDescription] as String?) ?? '',
      imagePath: data[FirestorePaths.fieldImagePath] as String?,
    );
  }

  /// Builds the Firestore payload for creating/updating this expense.
  /// [ownerUid] is required explicitly rather than read from
  /// `FirebaseAuth.instance` here, so this model stays free of any
  /// Firebase-auth dependency (Single Responsibility / testability).
  Map<String, dynamic> toFirestoreMap({required String ownerUid}) {
    return {
      FirestorePaths.fieldName: name,
      FirestorePaths.fieldAmount: amount,
      FirestorePaths.fieldDate: date,
      FirestorePaths.fieldCategory: category.name,
      FirestorePaths.fieldDescription: description,
      FirestorePaths.fieldOwnerUid: ownerUid,
      if (imagePath != null) FirestorePaths.fieldImagePath: imagePath,
    };
  }
}

/// Firestore collection and field identifiers, kept in one place so a
/// schema change never turns into a repo-wide string search.
abstract final class FirestorePaths {
  static const String expensesCollection = 'expenses';

  // Document field keys for the `expenses` collection.
  static const String fieldOwnerUid = 'user';
  static const String fieldName = 'name';
  static const String fieldAmount = 'amount';
  static const String fieldDate = 'date';
  static const String fieldCategory = 'category';
  static const String fieldDescription = 'description';
  static const String fieldImagePath = 'image-path';
}

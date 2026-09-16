import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/expense_category.dart';
import '../models/expense_model.dart';
import 'expense_repository.dart';

/// [ExpenseRepository] implementation backed by Cloud Firestore.
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection(FirestorePaths.expensesCollection);

  @override
  Stream<List<ExpenseModel>> watchExpenses(String ownerUid) {
    return _expensesCollection
        .where(FirestorePaths.fieldOwnerUid, isEqualTo: ownerUid)
        .snapshots()
        .map(_mapSnapshotToExpenses);
  }

  @override
  Stream<List<ExpenseModel>> watchExpensesByCategory(
    String ownerUid,
    ExpenseCategory category,
  ) {
    return _expensesCollection
        .where(FirestorePaths.fieldOwnerUid, isEqualTo: ownerUid)
        .where(FirestorePaths.fieldCategory, isEqualTo: category.name)
        .snapshots()
        .map(_mapSnapshotToExpenses);
  }

  @override
  Future<void> addExpense(
    ExpenseModel expense, {
    required String ownerUid,
  }) {
    return _expensesCollection.add(
      expense.toFirestoreMap(ownerUid: ownerUid),
    );
  }

  @override
  Future<Map<String, dynamic>> deleteExpense(String expenseId) async {
    final document = _expensesCollection.doc(expenseId);
    final snapshot = await document.get();
    final data = snapshot.data() ?? const <String, dynamic>{};
    await document.delete();
    return data;
  }

  @override
  Future<void> restoreExpense(
    String expenseId,
    Map<String, dynamic> data,
  ) {
    return _expensesCollection.doc(expenseId).set(data);
  }

  List<ExpenseModel> _mapSnapshotToExpenses(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => ExpenseModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}

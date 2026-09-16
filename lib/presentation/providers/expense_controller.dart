import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler_service.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/image_storage_service.dart';
import 'repository_providers.dart';

/// Mediates between the "add expense" / expense-list views and the
/// [ExpenseRepository] + [ImageStorageService].
///
/// Keeping image persistence and Firestore writes orchestrated here (rather
/// than inline in a widget, as the original `new_expense.dart` did) means
/// the same submit/delete/restore logic can be reused by any screen and
/// unit-tested without a widget tree.
class ExpenseController {
  ExpenseController(this._repository, this._imageStorage, this._errorHandler);

  final ExpenseRepository _repository;
  final ImageStorageService _imageStorage;
  final ErrorHandlerService _errorHandler;

  /// Persists [receiptImage] (if any), then writes [draft] to the
  /// repository under [ownerUid].
  Future<void> submitExpense({
    required ExpenseModel draft,
    required String ownerUid,
    File? receiptImage,
  }) {
    return _run(() async {
      String? imagePath = draft.imagePath;
      if (receiptImage != null) {
        final savedImage = await _imageStorage.persist(receiptImage);
        imagePath = savedImage.path;
      }

      final expenseToSave = ExpenseModel(
        id: draft.id,
        name: draft.name,
        amount: draft.amount,
        date: draft.date,
        category: draft.category,
        description: draft.description,
        imagePath: imagePath,
      );

      await _repository.addExpense(expenseToSave, ownerUid: ownerUid);
    });
  }

  /// Deletes an expense and returns its raw payload so the caller can offer
  /// an "Undo" affordance via [restoreExpense].
  Future<Map<String, dynamic>> deleteExpense(String expenseId) {
    return _run(() => _repository.deleteExpense(expenseId));
  }

  Future<void> restoreExpense(String expenseId, Map<String, dynamic> data) {
    return _run(() => _repository.restoreExpense(expenseId, data));
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      throw _errorHandler.normalize(error, stackTrace);
    }
  }
}

final expenseControllerProvider = Provider<ExpenseController>((ref) {
  return ExpenseController(
    ref.watch(expenseRepositoryProvider),
    ref.watch(imageStorageServiceProvider),
    ref.watch(errorHandlerServiceProvider),
  );
});

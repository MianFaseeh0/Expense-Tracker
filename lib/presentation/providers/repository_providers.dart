import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/error_handler_service.dart';
import '../../data/repositories/authentication_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/firebase_authentication_repository.dart';
import '../../data/repositories/firestore_expense_repository.dart';
import '../../data/repositories/image_storage_service.dart';
import '../../data/repositories/local_image_storage_service.dart';
import '../../data/repositories/mlkit_receipt_scanner_service.dart';
import '../../data/repositories/receipt_scanner_service.dart';

/// Composition root: every concrete implementation is bound to its
/// abstract contract exactly once, here. Every other provider/controller
/// depends on the interface type, never the concrete class, so swapping an
/// implementation (e.g. for testing) means overriding one provider.
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return const ErrorHandlerService();
});

final authenticationRepositoryProvider = Provider<AuthenticationRepository>((
  ref,
) {
  return FirebaseAuthenticationRepository();
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return FirestoreExpenseRepository();
});

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return LocalImageStorageService();
});

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  final service = MlKitReceiptScannerService();
  // The recognizer holds a native (platform-channel) resource — release it
  // when the provider is torn down instead of leaking it. Bound to the
  // concrete type since disposal isn't part of the ReceiptScannerService
  // contract (callers of the interface shouldn't need to know about it).
  ref.onDispose(service.dispose);
  return service;
});

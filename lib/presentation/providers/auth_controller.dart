import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler_service.dart';
import '../../data/repositories/authentication_repository.dart';
import 'repository_providers.dart';

/// Mediates between the sign in/sign up views and [AuthenticationRepository].
///
/// Every method normalizes failures into an [AppException] via
/// [ErrorHandlerService] before rethrowing, so views only ever need to
/// catch one exception type and read `.message`.
class AuthController {
  AuthController(this._repository, this._errorHandler);

  final AuthenticationRepository _repository;
  final ErrorHandlerService _errorHandler;

  Future<User?> signIn({required String email, required String password}) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<User?> signUp({required String email, required String password}) {
    return _run(() => _repository.signUp(email: email, password: password));
  }

  Future<void> signOut() {
    return _run(_repository.signOut);
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      throw _errorHandler.normalize(error, stackTrace);
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    ref.watch(authenticationRepositoryProvider),
    ref.watch(errorHandlerServiceProvider),
  );
});

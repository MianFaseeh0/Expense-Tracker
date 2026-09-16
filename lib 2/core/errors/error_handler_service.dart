import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_exception.dart';

/// A single, injectable choke point for every error in the app.
///
/// Responsibilities are intentionally narrow (Single Responsibility):
///   1. Normalize any raw error into a typed [AppException].
///   2. Log it (swap [_log] for a crash-reporting SDK later without
///      touching a single call site).
///   3. Optionally surface a user-facing toast.
///
/// Because this is consumed through [ErrorHandlerService] rather than a
/// static/global function, it can be mocked in tests and swapped via
/// Riverpod overrides (Dependency Inversion).
class ErrorHandlerService {
  const ErrorHandlerService();

  /// Converts any thrown object into a stable, user-presentable
  /// [AppException], logging the original error/stack trace along the way.
  AppException normalize(Object error, [StackTrace? stackTrace]) {
    _log(error, stackTrace);

    if (error is AppException) return error;

    if (error is FirebaseAuthException) {
      return AuthenticationException(
        _messageForAuthCode(error),
        cause: error,
      );
    }

    if (error is FirebaseException) {
      return DataPersistenceException(
        error.message ?? 'A data error occurred. Please try again.',
        cause: error,
      );
    }

    return UnexpectedAppException(error);
  }

  /// Normalizes the error and immediately shows it as a toast. Returns the
  /// normalized [AppException] in case the caller also needs it (e.g. to
  /// decide whether to retry).
  AppException handle(Object error, [StackTrace? stackTrace]) {
    final normalized = normalize(error, stackTrace);
    _presentToUser(normalized.message);
    return normalized;
  }

  /// Wraps [operation], funneling any failure through [handle] and
  /// returning `null` on failure instead of letting it propagate. Handy for
  /// fire-and-forget UI actions (delete, undo, logout) where the caller
  /// just needs a success/failure signal.
  Future<T?> guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handle(error, stackTrace);
      return null;
    }
  }

  /// Wires this service into Flutter's and the platform's global error
  /// hooks so nothing crashes silently. Call once from `main()`.
  void attachGlobalHandlers() {
    FlutterError.onError = (details) {
      _log(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _log(error, stack);
      return true;
    };
  }

  void _presentToUser(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _log(Object error, StackTrace? stackTrace) {
    // Centralized so swapping in Crashlytics/Sentry later is a one-line
    // change instead of a repo-wide refactor.
    debugPrint('[ErrorHandlerService] $error');
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _messageForAuthCode(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

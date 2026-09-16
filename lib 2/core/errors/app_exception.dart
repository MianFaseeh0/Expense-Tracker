/// Base type for every recoverable failure the app raises deliberately.
///
/// Repositories and controllers should throw one of the concrete subtypes
/// below instead of letting a raw [Exception]/platform error escape,
/// so the presentation layer never has to guess what went wrong.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// A message that is safe and sensible to show to the user.
  final String message;

  /// The original error, kept for logging/debugging purposes only.
  final Object? cause;

  @override
  String toString() => message;
}

/// Raised when an operation required an authenticated user and none was
/// present (e.g. submitting an expense after a session expired).
final class UnauthenticatedException extends AppException {
  const UnauthenticatedException([
    super.message = 'You need to be signed in to do that.',
  ]);
}

/// Raised for any Firebase Authentication failure (sign in / sign up).
final class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.cause});
}

/// Raised when reading from or writing to Firestore fails.
final class DataPersistenceException extends AppException {
  const DataPersistenceException(super.message, {super.cause});
}

/// Raised when local file/image I/O (saving a receipt photo, etc.) fails.
final class FileStorageException extends AppException {
  const FileStorageException(super.message, {super.cause});
}

/// Catch-all for anything that doesn't fit a more specific category.
final class UnexpectedAppException extends AppException {
  const UnexpectedAppException(
    Object cause,
  ) : super('Something went wrong. Please try again.', cause: cause);
}

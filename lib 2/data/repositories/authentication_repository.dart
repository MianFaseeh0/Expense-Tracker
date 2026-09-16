import 'package:firebase_auth/firebase_auth.dart';

/// Abstraction over authentication so the presentation layer never talks
/// to `FirebaseAuth` directly (Dependency Inversion). Swapping providers
/// (Firebase, a mock for tests, another vendor) means writing one new
/// implementation of this contract.
abstract interface class AuthenticationRepository {
  User? get currentUser;

  Stream<User?> authStateChanges();

  Future<User?> signIn({required String email, required String password});

  Future<User?> signUp({required String email, required String password});

  Future<void> signOut();
}

import 'package:firebase_auth/firebase_auth.dart';

import 'authentication_repository.dart';

/// [AuthenticationRepository] implementation backed by Firebase Auth.
///
/// Raw [FirebaseAuthException]s are intentionally left to propagate — the
/// app's [ErrorHandlerService] is responsible for normalizing them, keeping
/// this class focused solely on talking to Firebase (Single Responsibility).
class FirebaseAuthenticationRepository implements AuthenticationRepository {
  FirebaseAuthenticationRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}

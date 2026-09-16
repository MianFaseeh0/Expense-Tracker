import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';

/// Live stream of the signed-in [User], `null` when signed out.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authenticationRepositoryProvider).authStateChanges();
});

/// Synchronous snapshot of the current user, falling back to whatever the
/// repository already knows while [authStateChangesProvider] is loading.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => ref.read(authenticationRepositoryProvider).currentUser,
  );
});

/// The signed-in user's display email, shown in the navigation drawer.
/// Replaces the old bare `stringProvider` from `name_provider.dart`.
final currentUserEmailProvider = StateProvider<String>((ref) => '');

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/errors/error_handler_service.dart';
import '../../providers/auth_controller.dart';
import '../../providers/repository_providers.dart';
import '../../providers/session_providers.dart';
import '../../views/authentication/sign_in_screen.dart';
import '../../views/expense/add_expense_screen.dart';

/// The app's single navigation drawer.
///
/// The original project shipped two separate, near-identical drawer
/// widgets (`screens/drawer.dart` and `widgets/drawer.dart`) — neither of
/// which was actually wired into a `Scaffold`, and the logout button in
/// one of them tried to build a `PopupMenuButton` without ever showing it,
/// so logging out silently did nothing. This single widget replaces both,
/// is actually attached to the home shell, and has working sign-out.
class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 36),
                  const SizedBox(width: 10),
                  Text(
                    'Expenso',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 26),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'Signed out',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.attach_money_outlined),
                label: const Text('ADD NEW EXPENSE'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddExpenseScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_outlined),
                label: const Text('LOG OUT'),
                onPressed: () => _signOut(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final errorHandler = ref.read(errorHandlerServiceProvider);

    try {
      await ref.read(authControllerProvider).signOut();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    } catch (error) {
      errorHandler.handle(error);
    }
  }
}

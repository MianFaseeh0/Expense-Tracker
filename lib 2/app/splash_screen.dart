import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../presentation/providers/repository_providers.dart';
import '../presentation/views/home/home_shell_screen.dart';
import '../presentation/views/onboarding/onboarding_screen.dart';

/// The animated brand splash shown while the app decides whether the user
/// already has a session. Previously defined inline inside `main.dart`
/// alongside `MyApp`; pulled out so `main.dart` only wires up the app.
class AppLaunchScreen extends ConsumerStatefulWidget {
  const AppLaunchScreen({super.key});

  @override
  ConsumerState<AppLaunchScreen> createState() => _AppLaunchScreenState();
}

class _AppLaunchScreenState extends ConsumerState<AppLaunchScreen> {
  static const _splashDuration = Duration(milliseconds: 3500);

  @override
  void initState() {
    super.initState();
    Timer(_splashDuration, _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final isSignedIn =
        ref.read(authenticationRepositoryProvider).currentUser != null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            isSignedIn ? const HomeShellScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DefaultTextStyle(
          style: GoogleFonts.spaceMono(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          child: AnimatedTextKit(
            repeatForever: false,
            pause: const Duration(milliseconds: 200),
            animatedTexts: [
              RotateAnimatedText(
                'EXPENSO',
                duration: const Duration(milliseconds: 800),
              ),
              RotateAnimatedText(
                'TRACK SMARTER',
                duration: const Duration(milliseconds: 700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

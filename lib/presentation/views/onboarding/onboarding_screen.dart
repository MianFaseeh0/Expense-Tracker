import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/asset_paths.dart';
import '../../widgets/buttons/glass_action_button.dart';
import '../authentication/sign_in_screen.dart';
import '../authentication/sign_up_screen.dart';

/// The pre-auth welcome screen offering "Log In" / "Sign Up".
///
/// Renamed from `StartupScreens` to `OnboardingScreen`, moved under
/// `presentation/views/onboarding/` alongside the rest of the view layer
/// instead of a `sign-login-screens/` folder that mixed views, buttons and
/// screens together.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _goToSignIn(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  void _goToSignUp(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 900,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Align(
                child: Hero(
                  tag: 'hello',
                  child: Lottie.asset(AssetPaths.gradientAnimation),
                ),
              ),
              Align(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      AssetPaths.onboardingIllustration,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      '"Track smart. Spend wiser. Live freer."',
                      style: GoogleFonts.spaceMono(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    GlassActionButton(
                      label: 'Log In',
                      onPressed: () => _goToSignIn(context),
                    ),
                    const SizedBox(height: 20),
                    GlassActionButton(
                      label: 'Sign Up',
                      onPressed: () => _goToSignUp(context),
                    ),
                    const Spacer(),
                    Text(
                      'Free. Private. Easy.',
                      style: GoogleFonts.spaceMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

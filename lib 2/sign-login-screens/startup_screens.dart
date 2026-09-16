import 'package:expensetracker/sign-login-screens/buttons.dart/button.dart';
import 'package:expensetracker/sign-login-screens/sign_in.dart';
import 'package:expensetracker/sign-login-screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class StartupScreens extends StatefulWidget {
  const StartupScreens({super.key});

  @override
  State<StartupScreens> createState() => _StartupScreensState();
}

class _StartupScreensState extends State<StartupScreens> {
  void _gotosignIn(context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SignIn()));
  }

  void _gotosignUp(context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SignUp()));
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
                alignment: Alignment.center,
                child: Hero(
                  tag: 'hello',
                  child: Lottie.asset('assets/json/gradient.json'),
                ),
              ),
              Align(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/json/online-math-tutoring-abstract-concept-vector-illustration-math-private-lessons-reach-your-academic-goals-online-education-quarantine-homeschooling-qualified-teachers-abstract-metaphor.png',
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
                    Button(
                      gotopage: () => _gotosignIn(context),
                      label: 'Log In',
                    ),
                    const SizedBox(height: 20),
                    Button(
                      gotopage: () => _gotosignUp(context),
                      label: 'Sign Up',
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

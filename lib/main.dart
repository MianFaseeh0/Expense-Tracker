import 'dart:async';

import 'package:expensetracker/screens/TabScreen.dart';
import 'package:expensetracker/firebase_options.dart';
import 'package:expensetracker/sign-login-screens/startup_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ThemeData theme = ThemeData(
    useMaterial3: true,

    textTheme: GoogleFonts.spaceMonoTextTheme(),
  );
  @override
  Widget build(context) {
    return MaterialApp(theme: theme, home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3500), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const TabScreen()));
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StartupScreens()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DefaultTextStyle(
          style: GoogleFonts.spaceMono(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          child: AnimatedTextKit(
            repeatForever: false,
            pause: const Duration(milliseconds: 200),
            animatedTexts: [
              RotateAnimatedText(
                'EXPENSO',
                duration: const Duration(milliseconds: 800), // 1 second
              ),
              RotateAnimatedText(
                'TRACK SMARTER',
                duration: const Duration(milliseconds: 700), // 1.5 seconds
              ),
            ],
          ),
        ),
      ),
    );
  }
}

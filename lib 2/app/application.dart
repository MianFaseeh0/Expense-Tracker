import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'splash_screen.dart';

/// The root widget of the app. Renamed from `MyApp` to `ExpensoApp` to
/// match the product name shown on the splash screen, and moved out of
/// `main.dart` so that file is left doing only bootstrapping.
class ExpensoApp extends StatelessWidget {
  const ExpensoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenso',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppLaunchScreen(),
    );
  }
}

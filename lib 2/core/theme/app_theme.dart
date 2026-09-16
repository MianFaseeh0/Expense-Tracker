import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single source of truth for the app's [ThemeData].
///
/// Pulling this out of `MyApp` keeps the app widget focused on composition
/// rather than styling, and gives every screen one place to look for
/// palette/typography decisions.
abstract final class AppTheme {
  static const Color primaryAccent = Colors.deepOrange;
  static const Color surfaceDark = Colors.black;
  static const Color surfaceLight = Colors.white;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.spaceMonoTextTheme(),
      colorScheme: ColorScheme.fromSeed(seedColor: primaryAccent),
    );
  }
}

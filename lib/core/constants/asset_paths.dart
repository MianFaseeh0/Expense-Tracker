/// Centralized registry of every static asset used across the app.
///
/// Keeping paths in one place means a renamed or moved asset only needs to
/// be updated here instead of being hunted down across every widget.
abstract final class AssetPaths {
  static const String gradientAnimation = 'assets/json/gradient.json';
  static const String homeBackground = 'assets/json/homepage_background.png';
  static const String brandLogo =
      'assets/bwink_bld_03_single_03-removebg-preview.png';
  static const String onboardingIllustration =
      'assets/json/online-math-tutoring-abstract-concept-vector-illustration-math-private-lessons-reach-your-academic-goals-online-education-quarantine-homeschooling-qualified-teachers-abstract-metaphor.png';
}

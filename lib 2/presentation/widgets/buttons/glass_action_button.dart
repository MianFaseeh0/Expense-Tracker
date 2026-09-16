import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted-glass, pill-shaped tap target used on the onboarding screen.
///
/// Renamed from `Button` (too generic to search for) to `GlassActionButton`,
/// which documents both what it looks like and what it's for.
class GlassActionButton extends StatelessWidget {
  const GlassActionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(60, 118, 118, 118).withValues(
                alpha: .5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: .8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({required this.gotopage, required this.label, super.key});

  final void Function() gotopage;
  final String label;

  @override
  Widget build(context) {
    return InkWell(
      onTap: gotopage,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                60,
                118,
                118,
                118,
              ).withValues(alpha: .5),
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

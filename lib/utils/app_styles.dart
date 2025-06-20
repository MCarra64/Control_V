import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryGreen = Color.fromARGB(255,35,83,71);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color lightBackground = Color.fromARGB(255, 255,242,223);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B5E20);
  static const Color textLight = Color.fromARGB(255,208,238,232);
  static const Color greenBackground = Color(0xFFC8E6C9);

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: AppStyles.textLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  );
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0D3B85);
  static const Color backgroundWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF666666);
  static const Color dividerGrey = Color(0xFFE0E0E0);
  static const Color inputBg = Color(0xFFF5F5F3);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      background: backgroundWhite,
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: textLight,
        height: 1.5,
      ),
    ),
  );
}

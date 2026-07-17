import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Professional High-Contrast Palette
  static const Color primaryColor = Color(0xFF4F46E5); // Electric Indigo
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondaryColor = Color(0xFFF3F4F6); // Light Grey
  
  static const Color backgroundLight = Color(0xFFFFFFFF); // Crisp White
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF111827); // Pitch Black text
  static const Color textLight = Color(0xFF4B5563); // Slate Grey

  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
      
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold, letterSpacing: -1.0),
        displayMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: textDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textLight, fontSize: 14),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.inter(color: textDark, fontSize: 18, fontWeight: FontWeight.w700),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textDark, // High contrast black buttons
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pitch Black
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: Color(0xFF1F2937),
        surface: Color(0xFF111827),
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1.0),
        displayMedium: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // High contrast white buttons
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF374151)),
        ),
      ),
    );
  }
}

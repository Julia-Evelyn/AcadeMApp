import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getLightTheme(Color corDestaque, {bool usarFonteDislexia = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: corDestaque,
      primary: corDestaque, 
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: usarFonteDislexia ? GoogleFonts.lexend().fontFamily : null,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
    );
  }

  static ThemeData getDarkTheme(Color corDestaque, {bool usarFonteDislexia = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: corDestaque,
      primary: corDestaque, 
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: usarFonteDislexia ? GoogleFonts.lexend().fontFamily : null,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
    );
  }
}
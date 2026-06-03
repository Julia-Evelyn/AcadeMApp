import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getLightTheme(Color corDestaque) {
    // Cria a paleta garantindo que a cor primária seja a cor escolhida
    final scheme = ColorScheme.fromSeed(
      seedColor: corDestaque,
      primary: corDestaque, 
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
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

  static ThemeData getDarkTheme(Color corDestaque) {
    final scheme = ColorScheme.fromSeed(
      seedColor: corDestaque,
      primary: corDestaque, 
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
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
import 'package:flutter/material.dart';

import '../services/preferences/app_preferences_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    required AppPreferencesService preferencesService,
    required ThemeMode initialThemeMode,
    required Color initialAccentColor,
  }) : _preferencesService = preferencesService,
       themeMode = initialThemeMode,
       corDestaque = initialAccentColor;

  final AppPreferencesService _preferencesService;

  ThemeMode themeMode;
  Color corDestaque;

  static const List<Color> coresDisponiveis = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  Future<void> mudarCor(Color novaCor) async {
    corDestaque = novaCor;
    notifyListeners();
    await _preferencesService.saveAccentColorValue(novaCor.toARGB32());
  }

  Future<void> mudarTema(ThemeMode modo) async {
    themeMode = modo;
    notifyListeners();
    await _preferencesService.saveThemeMode(modo);
  }
}

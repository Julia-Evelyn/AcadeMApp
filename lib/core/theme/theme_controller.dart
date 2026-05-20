import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  ThemeController() {
    carregarTema();
  }

  Future<void> carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final temaSalvo = prefs.getString('tema_escolhido');

    if (temaSalvo == 'claro') {
      themeMode = ThemeMode.light;
    } else if (temaSalvo == 'escuro') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> mudarTema(ThemeMode novoTema) async {
    themeMode = novoTema;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    if (novoTema == ThemeMode.light) {
      await prefs.setString('tema_escolhido', 'claro');
    } else if (novoTema == ThemeMode.dark) {
      await prefs.setString('tema_escolhido', 'escuro');
    } else {
      await prefs.setString('tema_escolhido', 'sistema');
    }
  }
}

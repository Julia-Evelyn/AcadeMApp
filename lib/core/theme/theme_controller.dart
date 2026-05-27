import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  Color corDestaque = Colors.blue;

  // Lista com cores de destaque do app
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

  ThemeController() {
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    
    final temaSalvo = prefs.getString('theme_mode');
    if (temaSalvo == 'light') {
      themeMode = ThemeMode.light;
    } else if (temaSalvo == 'dark') {
      themeMode = ThemeMode.dark;
    }

    final corSalva = prefs.getInt('cor_destaque');
    if (corSalva != null) {
      corDestaque = Color(corSalva);
    }
    
    notifyListeners();
  }

// pula a função mudarTema 

  void mudarCor(Color novaCor) async {
    corDestaque = novaCor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cor_destaque', novaCor.toARGB32()); 
  }

  void mudarTema(ThemeMode modo) async {
    themeMode = modo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', modo.name);
  }
}
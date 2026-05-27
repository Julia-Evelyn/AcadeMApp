import 'package:flutter/material.dart';

import '../../../features/perfil/model/perfil_data.dart';
import 'key_value_store.dart';

class AppPreferencesService {
  AppPreferencesService(this._store);

  static const int defaultAlertMinutes = 45;
  static const int defaultAccentColorValue = 0xFF2196F3;

  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'cor_destaque';
  static const String _alertMinutesKey = 'tempo_alerta';
  static const String _profileNameKey = 'perfil_nome';
  static const String _profileLastNameKey = 'perfil_sobrenome';
  static const String _profileWeightKey = 'perfil_peso';
  static const String _profileHeightKey = 'perfil_altura';
  static const String _profileImagePathKey = 'perfil_imagem_caminho';

  final KeyValueStore _store;

  Future<ThemeMode> loadThemeMode() async {
    final savedThemeMode = await _store.getString(_themeModeKey);

    return switch (savedThemeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _store.setString(_themeModeKey, themeMode.name);
  }

  Future<int> loadAccentColorValue() async {
    return await _store.getInt(_accentColorKey) ?? defaultAccentColorValue;
  }

  Future<void> saveAccentColorValue(int colorValue) async {
    await _store.setInt(_accentColorKey, colorValue);
  }

  Future<int> loadAlertMinutes() async {
    return await _store.getInt(_alertMinutesKey) ?? defaultAlertMinutes;
  }

  Future<void> saveAlertMinutes(int minutes) async {
    if (minutes <= 0) {
      throw ArgumentError.value(
        minutes,
        'minutes',
        'O tempo de alerta deve ser maior que zero.',
      );
    }

    await _store.setInt(_alertMinutesKey, minutes);
  }

  Future<PerfilData> loadPerfilData() async {
    return PerfilData(
      nome: await _store.getString(_profileNameKey) ?? '',
      sobrenome: await _store.getString(_profileLastNameKey) ?? '',
      peso: await _store.getString(_profileWeightKey) ?? '',
      altura: await _store.getString(_profileHeightKey) ?? '',
      caminhoImagem: await _store.getString(_profileImagePathKey),
    );
  }

  Future<void> savePerfilData(PerfilData data) async {
    await _store.setString(_profileNameKey, data.nome);
    await _store.setString(_profileLastNameKey, data.sobrenome);
    await _store.setString(_profileWeightKey, data.peso);
    await _store.setString(_profileHeightKey, data.altura);

    if (data.caminhoImagem != null) {
      await _store.setString(_profileImagePathKey, data.caminhoImagem!);
    }
  }

  Future<String> loadProfileDisplayName() async {
    final profile = await loadPerfilData();
    final name = profile.nome.trim();
    return name.isEmpty ? 'Atleta' : name;
  }
}

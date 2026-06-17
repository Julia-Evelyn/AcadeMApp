import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_database_service.dart';
import '../../../features/perfil/model/perfil_data.dart';
import 'key_value_store.dart';

class AppPreferencesService {
  AppPreferencesService(this._store, this._dbService);

  static const int defaultAlertMinutes = 30;
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
  final FirebaseDatabaseService _dbService;

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
    String nome = await _store.getString(_profileNameKey) ?? '';
    String sobrenome = await _store.getString(_profileLastNameKey) ?? '';
    String peso = await _store.getString(_profileWeightKey) ?? '';
    String altura = await _store.getString(_profileHeightKey) ?? '';
    String? caminhoImagem = await _store.getString(_profileImagePathKey);

    if (nome.isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final dadosRemotos = await _dbService.buscarDados(
            'usuarios_perfil/${user.uid}',
          );
          if (dadosRemotos.isNotEmpty) {
            final dados = dadosRemotos.first;
            nome = dados['nome'] ?? '';
            sobrenome = dados['sobrenome'] ?? '';
            peso = dados['peso'] ?? '';
            altura = dados['altura'] ?? '';
            caminhoImagem = dados['caminhoImagem'];

            await _store.setString(_profileNameKey, nome);
            await _store.setString(_profileLastNameKey, sobrenome);
            await _store.setString(_profileWeightKey, peso);
            await _store.setString(_profileHeightKey, altura);
            if (caminhoImagem != null) {
              await _store.setString(_profileImagePathKey, caminhoImagem);
            }
          }
        }
      } catch (_) {}
    }

    return PerfilData(
      nome: nome,
      sobrenome: sobrenome,
      peso: peso,
      altura: altura,
      caminhoImagem: caminhoImagem,
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.salvarDado('usuarios_perfil/${user.uid}', {
          'nome': data.nome,
          'sobrenome': data.sobrenome,
          'peso': data.peso,
          'altura': data.altura,
          'caminhoImagem': data.caminhoImagem,
        });
      }
    } catch (_) {}
  }

  Future<String> loadProfileDisplayName() async {
    final profile = await loadPerfilData();
    final name = profile.nome.trim();
    return name.isEmpty ? 'Atleta' : name;
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_database_service.dart';
import '../../../features/perfil/model/perfil_data.dart';
import 'key_value_store.dart';

class AppPreferencesService {
  // Tornamos o dbService opcional para não quebrar o seu arquivo de testes antigos!
  AppPreferencesService(this._store, [FirebaseDatabaseService? dbService])
      : _dbService = dbService ?? FirebaseDatabaseService();

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
  static const String _fontDyslexiaKey = 'usar_fonte_dislexia';

  final KeyValueStore _store;
  final FirebaseDatabaseService _dbService;

  Future<bool> loadUsarFonteDislexia() async {
    final value = await _store.getString(_fontDyslexiaKey);
    return value == 'true';
  }

  Future<void> saveUsarFonteDislexia(bool value) async {
    await _store.setString(_fontDyslexiaKey, value.toString());
  }

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

  Future<void> forcarSincronizacao(User user) async {
    try {
      final dadosRemotos = await _dbService.buscarDados(
        'usuarios_perfil/${user.uid}',
      );
      if (dadosRemotos.isNotEmpty) {
        final dados = dadosRemotos.first;
        await _store.setString(_profileNameKey, dados['nome'] ?? '');
        await _store.setString(_profileLastNameKey, dados['sobrenome'] ?? '');
        await _store.setString(_profileWeightKey, dados['peso'] ?? '');
        await _store.setString(_profileHeightKey, dados['altura'] ?? '');

        if (dados['caminhoImagem'] != null) {
          await _store.setString(_profileImagePathKey, dados['caminhoImagem']);
        }
      }

      final corridasRemotas = await _dbService.buscarDados('usuarios_corridas/${user.uid}');
      if (corridasRemotas.isNotEmpty) {
        List<String> historicoCorridas = corridasRemotas.map((c) => c['texto'].toString()).toList();
        // Usamos o SharedPreferences direto aqui para garantir compatibilidade
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('historico_corridas', historicoCorridas);
      }
    } catch (e) {
      debugPrint('Erro na sincronizacao: $e');
    }
  }

  Future<PerfilData> loadPerfilData() async {
    String nome = await _store.getString(_profileNameKey) ?? '';
    String sobrenome = await _store.getString(_profileLastNameKey) ?? '';
    String peso = await _store.getString(_profileWeightKey) ?? '';
    String altura = await _store.getString(_profileHeightKey) ?? '';
    String? caminhoImagem = await _store.getString(_profileImagePathKey);

    if (nome.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await forcarSincronizacao(user);
        nome = await _store.getString(_profileNameKey) ?? '';
        sobrenome = await _store.getString(_profileLastNameKey) ?? '';
        peso = await _store.getString(_profileWeightKey) ?? '';
        altura = await _store.getString(_profileHeightKey) ?? '';
        caminhoImagem = await _store.getString(_profileImagePathKey);
      }
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
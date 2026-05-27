import 'package:academyapp/core/services/preferences/app_preferences_service.dart';
import 'package:academyapp/core/services/preferences/key_value_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeKeyValueStore implements KeyValueStore {
  final Map<String, Object?> _values = {};

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _values[key] = value;
  }
}

void main() {
  group('AppPreferencesService', () {
    late AppPreferencesService service;

    setUp(() {
      service = AppPreferencesService(FakeKeyValueStore());
    });

    test('retorna o modo do sistema por padrao', () async {
      expect(await service.loadThemeMode(), ThemeMode.system);
    });

    test('salva e carrega o tema escolhido', () async {
      await service.saveThemeMode(ThemeMode.dark);

      expect(await service.loadThemeMode(), ThemeMode.dark);
    });

    test('salva e carrega o tempo do alerta', () async {
      await service.saveAlertMinutes(30);

      expect(await service.loadAlertMinutes(), 30);
    });

    test('valida o tempo minimo do alerta', () async {
      expect(() => service.saveAlertMinutes(0), throwsA(isA<ArgumentError>()));
    });
  });
}

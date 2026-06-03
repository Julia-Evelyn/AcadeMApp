import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
}

class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore._(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesStore> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesStore._(preferences);
  }

  @override
  Future<String?> getString(String key) async => _preferences.getString(key);

  @override
  Future<int?> getInt(String key) async => _preferences.getInt(key);

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }
}

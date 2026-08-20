import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._preferences);

  static AppPreferences? _instance;

  final SharedPreferences _preferences;

  static Future<AppPreferences> init({SharedPreferences? preferences}) async {
    return _instance = AppPreferences(preferences ?? await SharedPreferences.getInstance());
  }

  static AppPreferences get instance {
    final preferences = _instance;
    if (preferences == null) {
      throw StateError('AppPreferences.init() must be called before use.');
    }
    return preferences;
  }

  static void reset() {
    _instance = null;
  }

  String? getString(String key) => _preferences.getString(key);

  Future<bool> setString(String key, String value) => _preferences.setString(key, value);

  Future<bool> remove(String key) => _preferences.remove(key);

  Future<bool> clear() => _preferences.clear();
}

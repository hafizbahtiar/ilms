import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';

const _themeModeOptions = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._preferences) : super(_load(_preferences));

  static const _prefsKey = 'theme_mode';

  final AppPreferences _preferences;

  static ThemeMode _load(AppPreferences preferences) {
    switch (preferences.getString(_prefsKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    switch (mode) {
      case ThemeMode.light:
        await _preferences.setString(_prefsKey, 'light');
      case ThemeMode.dark:
        await _preferences.setString(_prefsKey, 'dark');
      case ThemeMode.system:
        await _preferences.remove(_prefsKey);
    }
  }
}

final themeModeControllerProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(AppPreferences.instance);
});

List<ThemeMode> themeModeOptions() => _themeModeOptions;

String themeModeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System default';
  }
}

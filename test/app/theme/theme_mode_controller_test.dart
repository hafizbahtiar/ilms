import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/theme_mode_controller.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppPreferences.reset);

  test('defaults to system mode when nothing is stored', () {
    final controller = ThemeModeController(AppPreferences.instance);

    expect(controller.state, ThemeMode.system);
  });

  test('setMode updates state and persists the selection', () async {
    final controller = ThemeModeController(AppPreferences.instance);

    await controller.setMode(ThemeMode.dark);

    expect(controller.state, ThemeMode.dark);
    expect(AppPreferences.instance.getString('theme_mode'), 'dark');
  });

  test('persisted selection is restored on a new controller', () async {
    final controller = ThemeModeController(AppPreferences.instance);
    await controller.setMode(ThemeMode.light);

    final restored = ThemeModeController(AppPreferences.instance);

    expect(restored.state, ThemeMode.light);
  });

  test('setMode to system removes the stored key', () async {
    final controller = ThemeModeController(AppPreferences.instance);
    await controller.setMode(ThemeMode.dark);
    await controller.setMode(ThemeMode.system);

    expect(controller.state, ThemeMode.system);
    expect(AppPreferences.instance.getString('theme_mode'), isNull);
  });
}

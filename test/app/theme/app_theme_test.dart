import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/app.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';

void main() {
  tearDown(AppConfig.reset);

  test('light theme uses CelcomDigi navy and Digi yellow', () {
    expect(AppTheme.light.colorScheme.primary, const Color(0xFF001871));
    expect(AppTheme.light.colorScheme.secondary, const Color(0xFFFFE600));
    expect(AppTheme.light.brightness, Brightness.light);
  });

  test('dark theme uses the same brand anchors', () {
    expect(AppTheme.dark.colorScheme.primary, const Color(0xFF001871));
    expect(AppTheme.dark.colorScheme.secondary, const Color(0xFFFFE600));
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('light theme covers buttons, fields, and outline', () {
    final theme = AppTheme.light;
    final outline = theme.outlinedButtonTheme.style?.side?.resolve({});
    final focusedBorder = theme.inputDecorationTheme.focusedBorder as OutlineInputBorder?;

    expect(theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}), const Color(0xFF001871));
    expect(theme.textButtonTheme.style?.foregroundColor?.resolve({}), const Color(0xFF001871));
    expect(outline?.color, const Color(0xFF001871));
    expect(focusedBorder?.borderSide.color, const Color(0xFF001871));
    expect(theme.floatingActionButtonTheme.backgroundColor, const Color(0xFFFFE600));
    expect(theme.colorScheme.outline, isNotNull);
  });

  testWidgets('app enables system light and dark themes', (tester) async {
    await AppConfig.init(flavor: AppFlavor.dev, loader: (_) async => {'APP_ENV': 'dev'});

    await tester.pumpWidget(const App());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.colorScheme.primary, AppTheme.navy);
    expect(app.theme?.colorScheme.secondary, AppTheme.yellow);
    expect(app.darkTheme?.colorScheme.primary, AppTheme.navy);
    expect(app.darkTheme?.colorScheme.secondary, AppTheme.yellow);
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilms/app/app.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoSessionAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login({required String username, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> autoLogin() async {
    throw Exception('No session');
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getForgotPasswordUrl() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppConfig.reset);
  tearDown(AppPreferences.reset);

  test('light theme uses CelcomDigi navy and Digi yellow', () {
    expect(AppTheme.light.colorScheme.primary, const Color(0xFF001871));
    expect(AppTheme.light.colorScheme.secondary, const Color(0xFFFFE600));
    expect(AppTheme.light.colorScheme.tertiary, AppTheme.success);
    expect(AppTheme.light.brightness, Brightness.light);
  });

  test('dark theme uses the same brand anchors', () {
    expect(AppTheme.dark.colorScheme.primary, const Color(0xFF001871));
    expect(AppTheme.dark.colorScheme.secondary, const Color(0xFFFFE600));
    expect(AppTheme.dark.colorScheme.tertiary, AppTheme.successDark);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('dark theme lifts canvas so surface steps are distinguishable', () {
    final theme = AppTheme.dark;
    final cs = theme.colorScheme;
    final background = theme.scaffoldBackgroundColor;

    expect(background, isNot(cs.surface));
    expect(cs.surface, isNot(cs.surfaceContainerHigh));
    expect(cs.surfaceContainerLow, isNot(cs.surfaceContainerHigh));
    expect(background.computeLuminance(), lessThan(cs.surface.computeLuminance()));
    expect(cs.surface.computeLuminance(), lessThan(cs.surfaceContainerHigh.computeLuminance()));
    expect(cs.outlineVariant.computeLuminance(), greaterThan(cs.surface.computeLuminance()));
    // Mid-navy fills made the last dark theme look like a blue room.
    // Charcoal canvases keep blue only as a whisper (B − R stays small).
    expect((background.b * 255.0).round() - (background.r * 255.0).round(), lessThan(24));
  });

  test('dark theme uses yellow for interactive chrome', () {
    final theme = AppTheme.dark;
    final outline = theme.outlinedButtonTheme.style?.side?.resolve({});
    final focusedBorder = theme.inputDecorationTheme.focusedBorder as OutlineInputBorder?;

    expect(theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}), AppTheme.yellow);
    expect(theme.textButtonTheme.style?.foregroundColor?.resolve({}), AppTheme.yellow);
    expect(outline?.color, AppTheme.yellow);
    expect(focusedBorder?.borderSide.color, AppTheme.yellow);
    expect(theme.bottomNavigationBarTheme.selectedItemColor, AppTheme.yellow);
  });

  test('light theme exposes poppins textTheme roles', () {
    final theme = AppTheme.light;
    expect(theme.textTheme.titleLarge?.fontSize, 20);
    expect(theme.textTheme.bodyMedium?.fontSize, 14);
    expect(theme.primaryTextTheme.titleLarge?.fontSize, 20);
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWith((ref) => _NoSessionAuthRepository())],
        child: const App(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.colorScheme.primary, AppTheme.navy);
    expect(app.theme?.colorScheme.secondary, AppTheme.yellow);
    expect(app.darkTheme?.colorScheme.primary, AppTheme.navy);
    expect(app.darkTheme?.colorScheme.secondary, AppTheme.yellow);
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}

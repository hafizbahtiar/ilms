import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/app.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/pages/login_page.dart';
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
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppConfig.reset);
  tearDown(AppPreferences.reset);

  testWidgets('app opens on the login screen', (tester) async {
    await AppConfig.init(flavor: AppFlavor.dev, loader: (_) async => {'APP_ENV': 'dev'});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWith((ref) => _NoSessionAuthRepository())],
        child: const App(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Demo: admin / admin123456'), findsOneWidget);
  });
}

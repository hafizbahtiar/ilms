import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/features/auth/data/datasources/mock_auth_data_source.dart';
import 'package:ilms/features/auth/presentation/pages/login_page.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppPreferences.reset);

  testWidgets('shows validation errors when fields are empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authDataSourceProvider.overrideWith((ref) => MockAuthDataSource())],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Username is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('shows auth error for invalid credentials', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authDataSourceProvider.overrideWith((ref) => MockAuthDataSource())],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'wrong-user');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });
}

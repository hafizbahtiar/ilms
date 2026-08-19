import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('shows validation errors when fields are empty', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('shows auth error for invalid credentials', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'wrong@ilms.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}

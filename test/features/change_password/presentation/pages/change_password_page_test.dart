import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/change_password/presentation/pages/change_password_page.dart';

void main() {
  Widget buildHarness() {
    return ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openPage(WidgetTester tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows validation errors when fields are empty', (tester) async {
    await openPage(tester);

    await tester.tap(find.text('Update Password'));
    await tester.pump();

    expect(find.text('Current password is required.'), findsOneWidget);
    expect(find.text('New password is required.'), findsOneWidget);
    expect(find.text('Please confirm your new password.'), findsOneWidget);
  });

  testWidgets('validates new password length and mismatch', (tester) async {
    await openPage(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'old-pass');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.enterText(find.byType(TextFormField).at(2), '456');
    await tester.tap(find.text('Update Password'));
    await tester.pump();

    expect(find.text('Password must be at least 8 characters.'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('rejects new password without strong requirements', (tester) async {
    await openPage(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'old-pass');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Update Password'));
    await tester.pump();

    expect(find.text('Include uppercase, lowercase, number and symbol.'), findsOneWidget);
  });

  testWidgets('submits successfully and pops back', (tester) async {
    await openPage(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'old-pass');
    await tester.enterText(find.byType(TextFormField).at(1), 'NewPass123!');
    await tester.enterText(find.byType(TextFormField).at(2), 'NewPass123!');
    await tester.tap(find.text('Update Password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Password changed successfully.'), findsOneWidget);
    expect(find.byType(ChangePasswordPage), findsNothing);
  });
}

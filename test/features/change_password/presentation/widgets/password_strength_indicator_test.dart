import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/change_password/presentation/widgets/password_strength_indicator.dart';

void main() {
  group('passwordStrength', () {
    test('empty and very short passwords are weak', () {
      expect(passwordStrength(''), PasswordStrength.weak);
      expect(passwordStrength('abc'), PasswordStrength.weak);
      expect(passwordStrength('abcdefg'), PasswordStrength.weak);
    });

    test('two criteria met is fair', () {
      expect(passwordStrength('abcdefgh'), PasswordStrength.fair);
    });

    test('three to four criteria met is good', () {
      expect(passwordStrength('abcdefgh1'), PasswordStrength.good);
      expect(passwordStrength('Abcdefgh1'), PasswordStrength.good);
    });

    test('all criteria met is strong', () {
      expect(passwordStrength('Abcdef12!'), PasswordStrength.strong);
    });
  });

  testWidgets('indicator hides label when empty and shows label as password changes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PasswordStrengthIndicator(password: '')),
      ),
    );
    expect(find.text('Weak'), findsNothing);
    expect(find.text('Strong'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PasswordStrengthIndicator(password: 'Abcdef12!')),
      ),
    );
    expect(find.text('Strong'), findsOneWidget);
  });

  testWidgets('requirements checklist ticks off as each criterion is met', (tester) async {
    Widget build(String password, String current) {
      return MaterialApp(
        home: Scaffold(
          body: PasswordRequirements(password: password, currentPassword: current),
        ),
      );
    }

    await tester.pumpWidget(build('', 'old-pass'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(6));

    await tester.pumpWidget(build('Abcdef12!', 'old-pass'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(6));
    expect(find.byIcon(Icons.circle_outlined), findsNothing);

    await tester.pumpWidget(build('Abcdef12!', 'Abcdef12!'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(5));
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
  });
}

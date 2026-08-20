import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_card.dart';

void main() {
  testWidgets('profile card shows user details', (tester) async {
    const user = AuthUser(
      id: '1',
      name: 'Administrator',
      email: 'admin@admin.com',
      roles: ['admin'],
      permissions: ['view-mobile-premise'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileCard(user: user, envName: 'dev'),
        ),
      ),
    );

    expect(find.text('Administrator'), findsOneWidget);
    expect(find.text('admin@admin.com'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
  });

  testWidgets('profile card triggers onTap', (tester) async {
    var tapped = false;
    const user = AuthUser(
      id: '1',
      name: 'Administrator',
      email: 'admin@admin.com',
      roles: ['admin'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileCard(
            user: user,
            envName: 'stg',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ProfileCard));
    expect(tapped, isTrue);
    expect(find.text('STG'), findsOneWidget);
  });
}

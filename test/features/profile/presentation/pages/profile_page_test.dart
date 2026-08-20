import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_state.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_controller.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_state.dart';
import 'package:ilms/features/profile/presentation/pages/profile_page.dart';
import 'package:ilms/features/profile/presentation/providers/profile_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppPreferences.reset);

  testWidgets('profile page shows fetched profile and permissions', (tester) async {
    const authUser = AuthUser(
      id: '1',
      name: 'Administrator',
      email: 'admin@admin.com',
      roles: ['admin'],
      permissions: ['view-mobile-premise', 'view-mobile-billboard', 'view-mobile-investigation'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => _FakeAuthController(const AuthState(user: authUser))),
          profileControllerProvider.overrideWith(
            (ref) => _FakeProfileController(
              const ProfileState(
                profile: ProfileUser(name: 'Administrator', email: 'admin@admin.com', phone: '0123456789'),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Administrator'), findsWidgets);
    expect(find.text('admin@admin.com'), findsWidgets);
    expect(find.text('0123456789'), findsOneWidget);
    expect(find.text('Premise Census'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._state) : super(_FakeAuthRepository());

  final AuthState _state;

  @override
  AuthState get state => _state;
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login({required String username, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> autoLogin() {
    throw UnimplementedError();
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}
}

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._state) : super(_FakeProfileRepository());

  final ProfileState _state;

  @override
  ProfileState get state => _state;

  @override
  Future<void> fetchProfile() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<ProfileUser> getProfile() {
    throw UnimplementedError();
  }
}

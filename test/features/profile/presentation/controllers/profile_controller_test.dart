import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';
import 'package:ilms/features/profile/domain/exceptions/profile_exception.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_controller.dart';

class FakeSuccessProfileRepository implements ProfileRepository {
  @override
  Future<ProfileUser> getProfile() async {
    return const ProfileUser(
      name: 'Administrator',
      email: 'admin@admin.com',
      phone: '0123456789',
    );
  }
}

class FakeFailureProfileRepository implements ProfileRepository {
  @override
  Future<ProfileUser> getProfile() async {
    throw const ProfileException('Failed to load profile.');
  }
}

void main() {
  test('fetchProfile moves state to success', () async {
    final controller = ProfileController(FakeSuccessProfileRepository());

    await controller.fetchProfile();

    expect(controller.state.profile?.email, 'admin@admin.com');
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, isNull);
  });

  test('fetchProfile moves state to error', () async {
    final controller = ProfileController(FakeFailureProfileRepository());

    await controller.fetchProfile();

    expect(controller.state.profile, isNull);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, 'Failed to load profile.');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';
import 'package:ilms/features/profile/domain/exceptions/profile_exception.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_controller.dart';

class FakeSuccessProfileRepository implements ProfileRepository {
  FakeSuccessProfileRepository(this.profile);

  final ProfileUser profile;
  var fetchCount = 0;

  @override
  Future<ProfileUser> getProfile() async {
    fetchCount++;
    return profile;
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
    final controller = ProfileController(
      FakeSuccessProfileRepository(
        const ProfileUser(name: 'Administrator', email: 'admin@admin.com'),
      ),
    );

    await controller.fetchProfile();

    expect(controller.state.profile?.email, 'admin@admin.com');
    expect(controller.state.isLoading, false);
    expect(controller.state.isRefreshing, false);
    expect(controller.state.errorMessage, isNull);
  });

  test('fetchProfile moves state to error', () async {
    final controller = ProfileController(FakeFailureProfileRepository());

    await controller.fetchProfile();

    expect(controller.state.profile, isNull);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, 'Failed to load profile.');
  });

  test('fetchProfile refreshes silently when profile is cached', () async {
    const cached = ProfileUser(name: 'Administrator', email: 'admin@admin.com');
    const updated = ProfileUser(name: 'Updated Admin', email: 'updated@admin.com');
    final repository = _RefreshProfileRepository(first: cached, second: updated);
    final controller = ProfileController(repository);

    await controller.fetchProfile();
    expect(controller.state.profile, cached);

    await controller.fetchProfile();

    expect(controller.state.profile, updated);
    expect(controller.state.isLoading, false);
    expect(controller.state.isRefreshing, false);
    expect(repository.fetchCount, 2);
  });

  test('fetchProfile keeps cached profile when refresh fails', () async {
    const cached = ProfileUser(name: 'Administrator', email: 'admin@admin.com');
    final repository = _RefreshProfileRepository(first: cached, secondError: true);
    final controller = ProfileController(repository);

    await controller.fetchProfile();
    await controller.fetchProfile();

    expect(controller.state.profile, cached);
    expect(controller.state.errorMessage, isNull);
  });
}

class _RefreshProfileRepository implements ProfileRepository {
  _RefreshProfileRepository({required this.first, this.second, this.secondError = false});

  final ProfileUser first;
  final ProfileUser? second;
  final bool secondError;
  var fetchCount = 0;

  @override
  Future<ProfileUser> getProfile() async {
    fetchCount++;
    if (fetchCount == 1) return first;
    if (secondError) throw const ProfileException('Failed to load profile.');
    return second ?? first;
  }
}

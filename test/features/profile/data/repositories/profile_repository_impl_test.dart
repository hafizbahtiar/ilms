import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/profile/data/datasources/profile_data_source.dart';
import 'package:ilms/features/profile/data/models/profile_response_model.dart';
import 'package:ilms/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ilms/features/profile/domain/exceptions/profile_exception.dart';

class FakeProfileDataSource implements ProfileDataSource {
  @override
  Future<ProfileDataModel> getProfile() async {
    return const ProfileDataModel(
      name: 'Administrator',
      email: 'admin@admin.com',
      phone: '0123456789',
    );
  }
}

class FailingProfileDataSource implements ProfileDataSource {
  @override
  Future<ProfileDataModel> getProfile() async {
    throw const ProfileException('Failed to load profile.');
  }
}

void main() {
  test('getProfile returns ProfileUser from data source', () async {
    final repository = ProfileRepositoryImpl(FakeProfileDataSource());

    final profile = await repository.getProfile();

    expect(profile.name, 'Administrator');
    expect(profile.email, 'admin@admin.com');
    expect(profile.phone, '0123456789');
  });

  test('getProfile throws ProfileException', () async {
    final repository = ProfileRepositoryImpl(FailingProfileDataSource());

    expect(repository.getProfile, throwsA(isA<ProfileException>()));
  });
}

import 'package:ilms/features/profile/data/datasources/profile_data_source.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<ProfileUser> getProfile() async {
    final data = await _dataSource.getProfile();

    return ProfileUser(name: data.name ?? '', email: data.email ?? '', phone: data.phone);
  }
}

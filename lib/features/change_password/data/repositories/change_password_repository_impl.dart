import 'package:ilms/features/change_password/data/datasources/change_password_data_source.dart';
import 'package:ilms/features/change_password/domain/repositories/change_password_repository.dart';

class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  ChangePasswordRepositoryImpl(this._dataSource);

  final ChangePasswordDataSource _dataSource;

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _dataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}

import 'package:ilms/features/change_password/data/datasources/change_password_data_source.dart';

class MockChangePasswordDataSource implements ChangePasswordDataSource {
  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}

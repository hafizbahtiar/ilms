abstract class ChangePasswordDataSource {
  Future<void> changePassword({required String currentPassword, required String newPassword});
}

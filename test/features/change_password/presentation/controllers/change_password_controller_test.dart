import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/change_password/domain/exceptions/change_password_exception.dart';
import 'package:ilms/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:ilms/features/change_password/presentation/controllers/change_password_controller.dart';

class _FakeSuccessRepository implements ChangePasswordRepository {
  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}
}

class _FakeFailureRepository implements ChangePasswordRepository {
  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    throw const ChangePasswordException('Current password is incorrect.');
  }
}

void main() {
  test('changePassword returns true and clears state on success', () async {
    final controller = ChangePasswordController(_FakeSuccessRepository());

    final success = await controller.changePassword(currentPassword: 'old-pass', newPassword: 'new-pass');

    expect(success, isTrue);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, isNull);
  });

  test('changePassword returns false and exposes error on failure', () async {
    final controller = ChangePasswordController(_FakeFailureRepository());

    final success = await controller.changePassword(currentPassword: 'old-pass', newPassword: 'new-pass');

    expect(success, isFalse);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, 'Current password is incorrect.');
  });
}

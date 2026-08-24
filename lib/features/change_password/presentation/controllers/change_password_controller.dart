import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/change_password/domain/exceptions/change_password_exception.dart';
import 'package:ilms/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:ilms/features/change_password/presentation/controllers/change_password_state.dart';

class ChangePasswordController extends StateNotifier<ChangePasswordState> {
  ChangePasswordController(this._repository) : super(const ChangePasswordState());

  final ChangePasswordRepository _repository;

  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    state = const ChangePasswordState(isLoading: true);

    try {
      await _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      // autoDispose: the page can be popped (losing this controller's only
      // watcher, tearing it down) while the request is still in flight.
      if (!mounted) return false;
      state = const ChangePasswordState();
      return true;
    } on ChangePasswordException catch (error) {
      if (!mounted) return false;
      state = ChangePasswordState(errorMessage: error.message);
      return false;
    }
  }
}

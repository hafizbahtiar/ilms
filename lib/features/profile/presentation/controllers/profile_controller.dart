import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/profile/domain/exceptions/profile_exception.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> fetchProfile() async {
    state = const ProfileState(isLoading: true);

    try {
      final profile = await _repository.getProfile();
      state = ProfileState(profile: profile);
    } on ProfileException catch (error) {
      state = ProfileState(errorMessage: error.message);
    }
  }
}

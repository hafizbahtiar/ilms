import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/profile/domain/exceptions/profile_exception.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> fetchProfile() async {
    final cachedProfile = state.profile;
    final isInitialLoad = cachedProfile == null;

    state = ProfileState(
      isLoading: isInitialLoad,
      isRefreshing: !isInitialLoad,
      profile: cachedProfile,
      errorMessage: isInitialLoad ? null : state.errorMessage,
    );

    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;
      state = ProfileState(profile: profile);
    } on ProfileException catch (error) {
      if (!mounted) return;
      if (cachedProfile != null) {
        state = ProfileState(profile: cachedProfile);
        return;
      }
      state = ProfileState(errorMessage: error.message);
    }
  }
}

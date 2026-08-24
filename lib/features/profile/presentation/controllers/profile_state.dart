import 'package:ilms/features/profile/domain/entities/profile_user.dart';

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.profile,
  });

  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final ProfileUser? profile;
}

import 'package:ilms/features/profile/domain/entities/profile_user.dart';

class ProfileState {
  const ProfileState({this.isLoading = false, this.errorMessage, this.profile});

  final bool isLoading;
  final String? errorMessage;
  final ProfileUser? profile;
}

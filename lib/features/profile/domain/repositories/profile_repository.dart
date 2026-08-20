import 'package:ilms/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();
}

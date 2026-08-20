import 'package:ilms/features/profile/data/models/profile_response_model.dart';

abstract class ProfileDataSource {
  Future<ProfileDataModel> getProfile();
}

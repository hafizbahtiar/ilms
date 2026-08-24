import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/profile/data/models/profile_response_model.dart';
import 'package:ilms/features/profile/domain/exceptions/profile_exception.dart';

import 'profile_data_source.dart';

class ApiProfileDataSource implements ProfileDataSource {
  @override
  Future<ProfileDataModel> getProfile() async {
    try {
      final dio = DioClient.instance.dio;
      final response = await dio.post<Map<String, dynamic>>('/api/viewProfile', data: <String, dynamic>{});

      final payload = response.data;
      if (payload == null) {
        throw const ProfileException('Failed to load profile.');
      }

      final profileResponse = ProfileResponseModel.fromJson(payload);

      if (profileResponse.status != 'success' || profileResponse.data == null) {
        throw ProfileException(profileResponse.message ?? 'Failed to load profile.');
      }

      return profileResponse.data!;
    } on StateError {
      throw const ProfileException('Failed to load profile.');
    } on ProfileException {
      rethrow;
    } on DioException catch (e) {
      final message = extractDioErrorMessage(e) ?? 'Failed to load profile.';
      throw ProfileException(message);
    } catch (_) {
      throw const ProfileException('Failed to load profile.');
    }
  }
}

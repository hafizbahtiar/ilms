import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/auth/data/models/login_request_model.dart';
import 'package:ilms/features/auth/data/models/login_response_model.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

import 'auth_data_source.dart';

final _acceptAllStatuses = Options(validateStatus: _acceptAnyStatusCode);

bool _acceptAnyStatusCode(int? status) => true;

class ApiAuthDataSource implements AuthDataSource {
  @override
  Future<LoginDataModel> login({required String username, required String password}) async {
    try {
      final dio = DioClient.instance.dio;
      final request = LoginRequestModel(username: username, password: password);

      final response = await dio.post<Map<String, dynamic>>(
        '/api/login',
        data: request.toJson(),
        options: _acceptAllStatuses,
      );

      final payload = response.data;
      if (payload == null) {
        throw const AuthException('Invalid username or password.');
      }

      final loginResponse = LoginResponseModel.fromJson(payload);

      if (loginResponse.status != 'success' || loginResponse.data == null) {
        throw AuthException(loginResponse.message ?? 'Invalid username or password.');
      }

      final data = loginResponse.data!;
      final accessToken = data.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        DioClient.instance.setAccessToken(accessToken);
      }

      return data;
    } on StateError {
      throw const AuthException('Invalid username or password.');
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      final message = extractDioErrorMessage(e) ?? 'Invalid username or password.';
      throw AuthException(message);
    } catch (_) {
      throw const AuthException('Invalid username or password.');
    }
  }

  @override
  Future<LoginDataModel> autoLogin() async {
    try {
      final dio = DioClient.instance.dio;
      final response = await dio.post<Map<String, dynamic>>(
        '/api/autoLogin',
        data: <String, dynamic>{},
        options: _acceptAllStatuses,
      );

      final payload = response.data;
      if (payload == null) {
        throw const AuthException('Session expired.');
      }

      final loginResponse = LoginResponseModel.fromJson(payload);

      if (loginResponse.status != 'success' || loginResponse.data == null) {
        throw AuthException(loginResponse.message ?? 'Session expired.');
      }

      return loginResponse.data!;
    } on StateError {
      throw const AuthException('Session expired.');
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      final message = extractDioErrorMessage(e) ?? 'Session expired.';
      throw AuthException(message);
    } catch (_) {
      throw const AuthException('Session expired.');
    }
  }

  @override
  Future<void> logout() async {
    final dio = DioClient.instance.dio;
    await dio.post<Map<String, dynamic>>('/api/logout', data: <String, dynamic>{});
  }

  @override
  Future<String?> getForgotPasswordUrl() async {
    try {
      final dio = DioClient.instance.dio;
      final response = await dio.get<Map<String, dynamic>>('/api/forgotPasswordLink');

      final data = response.data?['data'];
      if (data is! Map) return null;

      final url = data['forgot_password_url'];
      return url is String && url.isNotEmpty ? url : null;
    } on DioException catch (e) {
      final message = extractDioErrorMessage(e) ?? 'Failed to fetch forgot password link.';
      throw AuthException(message);
    } catch (_) {
      throw const AuthException('Failed to fetch forgot password link.');
    }
  }
}

import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

import 'auth_data_source.dart';

String _detectPlatform() {
  // Backend expects a simple string. Keep this intentionally conservative.
  if (io.Platform.isAndroid) return 'android';
  if (io.Platform.isIOS) return 'ios';
  return io.Platform.operatingSystem;
}

String _onesignalPushIdPlaceholder() {
  // TODO: wire OneSignal push id when the app integrates notifications.
  return '';
}

class ApiAuthDataSource implements AuthDataSource {
  @override
  Future<Map<String, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap(<String, dynamic>{
        'email': email,
        'password': password,
        'platform': _detectPlatform(),
        'pushID': _onesignalPushIdPlaceholder(),
      });

      final dio = DioClient.instance.dio;
      final response = await dio.post(
        '/api/login',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final payload = response.data;
      if (payload is! Map) {
        throw const AuthException('Invalid email or password.');
      }

      // Expected: { status?, message?, data: { ... } }
      final data = payload['data'];
      final userMap = data is Map ? data : payload;

      if (userMap is! Map) {
        throw const AuthException('Invalid email or password.');
      }

      final name = userMap['name']?.toString() ?? '';
      final userEmail = userMap['email']?.toString() ?? email;

      // Backend response varies; pick a stable identifier if present.
      final id = (userMap['id'] ?? userMap['access_token'])?.toString() ?? '';

      return {'id': id, 'name': name, 'email': userEmail};
    } on StateError {
      // DioClient not initialized (likely widget/unit tests).
      throw const AuthException('Invalid email or password.');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Invalid email or password.';
      throw AuthException(message);
    } catch (_) {
      throw const AuthException('Invalid email or password.');
    }
  }
}

String? _extractErrorMessage(DioException e) {
  final data = e.response?.data;

  // Sometimes backend returns plain string error bodies.
  if (data is String && data.trim().isNotEmpty) return data.trim();

  // Common Laravel-style / API error shapes.
  if (data is Map) {
    final candidate = data['message'] ?? data['error'] ?? data['detail'] ?? data['title'];
    if (candidate is String && candidate.trim().isNotEmpty) return candidate.trim();
  }

  if (e.message != null && e.message!.trim().isNotEmpty) return e.message!.trim();
  return null;
}


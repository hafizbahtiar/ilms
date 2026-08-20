import 'package:dio/dio.dart';

import 'dio_client.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dioClient);

  final DioClient _dioClient;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requiresAuth = options.extra['requiresAuth'] ?? true;
    final token = _dioClient.accessToken;

    if (requiresAuth && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

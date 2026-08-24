import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/auth/data/datasources/api_auth_data_source.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

void main() {
  tearDown(() {
    AppConfig.reset();
    DioClient.reset();
  });

  Future<void> setupClient({required void Function(RequestOptions options, RequestInterceptorHandler handler) onRequest}) async {
    await AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev', 'BASE_URL': 'https://dev.example.com'},
    );

    final client = DioClient.create(AppConfig.instance);
    client.dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  }

  test('login surfaces API error message from non-2xx response', () async {
    await setupClient(
      onRequest: (options, handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 401,
            data: const {
              'status': 'error',
              'message': 'Invalid username or password.',
            },
          ),
        );
      },
    );

    final dataSource = ApiAuthDataSource();

    expect(
      () => dataSource.login(username: 'wrong', password: 'wrong-password'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Invalid username or password.',
        ),
      ),
    );
  });

  test('login surfaces friendly message on timeout', () async {
    await setupClient(
      onRequest: (options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
            message:
                'The request took longer than 0:00:30.000000 to receive data from the server and it was aborted.',
          ),
        );
      },
    );

    final dataSource = ApiAuthDataSource();

    expect(
      () => dataSource.login(username: 'admin', password: 'password123'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Unable to reach the server. Please check your connection and try again.',
        ),
      ),
    );
  });
}

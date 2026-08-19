import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/network/api_client.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/network_exception.dart';

void main() {
  tearDown(() {
    AppConfig.reset();
    DioClient.reset();
  });

  Future<AppConfig> loadConfig() {
    return AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev', 'BASE_URL': 'https://dev.example.com'},
    );
  }

  test('DioClient uses BASE_URL from AppConfig', () async {
    final config = await loadConfig();

    final client = DioClient.create(config);

    expect(client.dio.options.baseUrl, 'https://dev.example.com');
    expect(client.dio.options.connectTimeout, const Duration(seconds: 30));
  });

  test('get returns response data', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://dev.example.com'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {'id': 1},
            ),
          );
        },
      ),
    );
    final ApiClient client = DioClient(dio);

    final result = await client.get<Map<String, dynamic>>('/items/1');

    expect(result['id'], 1);
  });

  test('get maps Dio errors to NetworkException', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://dev.example.com'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
              message: 'timeout',
            ),
          );
        },
      ),
    );
    final client = DioClient(dio);

    expect(
      () => client.get<Map<String, dynamic>>('/items/1'),
      throwsA(isA<NetworkException>()),
    );
  });
}

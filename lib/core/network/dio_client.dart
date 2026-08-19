import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_client.dart';
import 'network_exception.dart';

class DioClient implements ApiClient {
  DioClient(this.dio);

  final Dio dio;

  static DioClient? _instance;

  static DioClient get instance {
    final client = _instance;
    if (client == null) {
      throw StateError('DioClient.create() must be called first.');
    }
    return client;
  }

  static DioClient create(AppConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    return _instance = DioClient(dio);
  }

  static void reset() {
    _instance = null;
  }

  @override
  Future<T> get<T>(String path, {Map<String, dynamic>? query}) {
    return _send(() => dio.get<T>(path, queryParameters: query));
  }

  @override
  Future<T> post<T>(String path, {Object? data}) {
    return _send(() => dio.post<T>(path, data: data));
  }

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Request failed',
        statusCode: error.response?.statusCode,
      );
    }
  }
}

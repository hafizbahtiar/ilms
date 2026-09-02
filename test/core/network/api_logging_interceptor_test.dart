import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/network/api_logging_interceptor.dart';
import 'package:ilms/core/network/dio_client.dart';

void main() {
  group('buildDioInterceptors', () {
    test('omits ApiLoggingInterceptor when verboseLogging is false', () {
      final interceptors = DioClient.buildDioInterceptors(
        DioClient(Dio()),
        verboseLogging: false,
      );

      expect(interceptors.whereType<ApiLoggingInterceptor>(), isEmpty);
    });

    test('includes ApiLoggingInterceptor when verboseLogging is true', () {
      final interceptors = DioClient.buildDioInterceptors(
        DioClient(Dio()),
        verboseLogging: true,
      );

      expect(interceptors.whereType<ApiLoggingInterceptor>(), hasLength(1));
    });
  });

  group('ApiLoggingInterceptor', () {
    test('logs request with method, uri, and form body', () {
      final logs = <String>[];
      final interceptor = ApiLoggingInterceptor(log: logs.add);
      final options = RequestOptions(
        path: '/api/premiseCensus/searchPrevPhase',
        method: 'POST',
        baseUrl: 'https://dev.example.com',
        queryParameters: {'page': 1, 'per_page': 15},
        data: FormData.fromMap({'parliament': 'Bukit Bintang'}),
      );

      interceptor.onRequest(options, _FakeRequestHandler());

      expect(logs, hasLength(1));
      expect(logs.single, contains('── API REQUEST ──'));
      expect(
        logs.single,
        contains('POST https://dev.example.com/api/premiseCensus/searchPrevPhase?page=1&per_page=15'),
      );
      expect(logs.single, contains('"parliament": "Bukit Bintang"'));
    });

    test('logs response with status and json body', () {
      final logs = <String>[];
      final interceptor = ApiLoggingInterceptor(log: logs.add);
      final options = RequestOptions(
        path: '/api/premiseCensus/searchPrevPhase',
        method: 'POST',
        baseUrl: 'https://dev.example.com',
      );

      interceptor.onResponse(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: {'status': 'success', 'data': []},
        ),
        _FakeResponseHandler(),
      );

      expect(logs, hasLength(1));
      expect(logs.single, contains('── API RESPONSE ──'));
      expect(logs.single, contains('Status: 200'));
      expect(logs.single, contains('"status": "success"'));
    });
  });
}

class _FakeRequestHandler implements RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeResponseHandler implements ResponseInterceptorHandler {
  @override
  void next(Response<dynamic> response) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/network/api_response_helper.dart';

RequestOptions _requestOptions() => RequestOptions(path: '/api/login');

void main() {
  group('extractDioErrorMessage', () {
    test('returns API message from response body', () {
      final message = extractDioErrorMessage(
        DioException(
          requestOptions: _requestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<Map<String, dynamic>>(
            requestOptions: _requestOptions(),
            statusCode: 401,
            data: {'status': 'error', 'message': 'Invalid username or password.'},
          ),
        ),
      );

      expect(message, 'Invalid username or password.');
    });

    test('returns friendly message for receive timeout', () {
      final message = extractDioErrorMessage(
        DioException(
          requestOptions: _requestOptions(),
          type: DioExceptionType.receiveTimeout,
          message:
              'The request took longer than 0:00:30.000000 to receive data from the server and it was aborted.',
        ),
      );

      expect(message, 'Unable to reach the server. Please check your connection and try again.');
    });

    test('returns friendly message for connection timeout', () {
      final message = extractDioErrorMessage(
        DioException(
          requestOptions: _requestOptions(),
          type: DioExceptionType.connectionTimeout,
          message: 'The request connection took longer than 0:00:30.000000 and it was aborted.',
        ),
      );

      expect(message, 'Unable to reach the server. Please check your connection and try again.');
    });

    test('returns friendly message for connection error', () {
      final message = extractDioErrorMessage(
        DioException(
          requestOptions: _requestOptions(),
          type: DioExceptionType.connectionError,
          message: 'Connection failed',
        ),
      );

      expect(message, 'Unable to connect to the server. Please check your connection and try again.');
    });

    test('ignores HTML error pages', () {
      final message = extractDioErrorMessage(
        DioException(
          requestOptions: _requestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<String>(
            requestOptions: _requestOptions(),
            statusCode: 502,
            data: '<html><body>Bad Gateway</body></html>',
          ),
        ),
      );

      expect(message, 'Server error. Please try again later.');
    });
  });
}

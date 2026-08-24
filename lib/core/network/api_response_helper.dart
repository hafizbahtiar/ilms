import 'package:dio/dio.dart';

class ApiResponseException implements Exception {
  const ApiResponseException(this.message);

  final String message;

  @override
  String toString() => message;
}

void ensureApiSuccess(Map<String, dynamic> payload, {String fallbackMessage = 'Request failed'}) {
  if (payload['status'] != 'success') {
    throw ApiResponseException(_messageFromPayload(payload) ?? fallbackMessage);
  }
}

String? _messageFromPayload(Map<String, dynamic> payload) {
  final message = payload['message'];
  if (message is String && message.trim().isNotEmpty) return message.trim();
  return null;
}

String? extractDioErrorMessage(DioException error) {
  final fromResponse = _messageFromResponseData(error.response?.data);
  if (fromResponse != null) return fromResponse;

  return _messageFromDioExceptionType(error);
}

String? _messageFromResponseData(dynamic data) {
  if (data is String) {
    final trimmed = data.trim();
    if (trimmed.isEmpty || trimmed.startsWith('<')) return null;
    return trimmed;
  }

  if (data is Map) {
    final candidate = data['message'] ?? data['error'] ?? data['detail'] ?? data['title'];
    if (candidate is String && candidate.trim().isNotEmpty) return candidate.trim();
  }

  return null;
}

String? _messageFromDioExceptionType(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Unable to reach the server. Please check your connection and try again.';
    case DioExceptionType.connectionError:
      return 'Unable to connect to the server. Please check your connection and try again.';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again later.';
      }
      return null;
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return null;
  }
}

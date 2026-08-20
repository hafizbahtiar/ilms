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
  final data = error.response?.data;

  if (data is String && data.trim().isNotEmpty) return data.trim();

  if (data is Map) {
    final candidate = data['message'] ?? data['error'] ?? data['detail'] ?? data['title'];
    if (candidate is String && candidate.trim().isNotEmpty) return candidate.trim();
  }

  if (error.message != null && error.message!.trim().isNotEmpty) {
    return error.message!.trim();
  }
  return null;
}

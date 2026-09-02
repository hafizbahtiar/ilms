import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs API method, URL, body, and response in debug builds.
class ApiLoggingInterceptor extends Interceptor {
  ApiLoggingInterceptor({void Function(String message)? log}) : _log = log ?? debugPrint;

  final void Function(String message) _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('── API REQUEST ──')
      ..writeln('${options.method} ${options.uri}')
      ..writeln('Body: ${_formatPayload(options.data)}');

    _log(buffer.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    final buffer = StringBuffer()
      ..writeln('── API RESPONSE ──')
      ..writeln('${request.method} ${request.uri}')
      ..writeln('Status: ${response.statusCode}')
      ..writeln('Body: ${_formatPayload(response.data)}');

    _log(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final buffer = StringBuffer()
      ..writeln('── API ERROR ──')
      ..writeln('${request.method} ${request.uri}')
      ..writeln('Type: ${err.type}')
      ..writeln('Message: ${err.message ?? '(none)'}');

    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      buffer.writeln('Status: $statusCode');
    }

    final responseData = err.response?.data;
    if (responseData != null) {
      buffer.writeln('Body: ${_formatPayload(responseData)}');
    }

    _log(buffer.toString());
    handler.next(err);
  }

  static String _formatPayload(Object? data) {
    if (data == null) {
      return '(empty)';
    }

    if (data is FormData) {
      final fields = {for (final field in data.fields) field.key: field.value};
      final files = [
        for (final file in data.files) '${file.key}: ${file.value.filename ?? 'file'} (${file.value.length} bytes)',
      ];

      return const JsonEncoder.withIndent('  ').convert({'fields': fields, if (files.isNotEmpty) 'files': files});
    }

    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return data;
      }
    }

    return data.toString();
  }
}

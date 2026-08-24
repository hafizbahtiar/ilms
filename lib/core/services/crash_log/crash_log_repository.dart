import 'dart:convert';

import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/core/services/crash_log/mobile_error_log.dart';

/// Sends crash / error logs to `POST /api/mobileErrorLog`.
class CrashLogRepository {
  CrashLogRepository({FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  static const String endpoint = '/api/mobileErrorLog';

  final FormDataBuilder _formDataBuilder;

  Future<void> send(MobileErrorLog log) async {
    final formData = await _formDataBuilder.fromMap({'data': jsonEncode(log.toJson())});
    await DioClient.instance.dio.post<void>(endpoint, data: formData);
  }
}

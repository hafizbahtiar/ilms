import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/investigation/data/datasources/investigation_data_source.dart';
import 'package:ilms/features/investigation/data/models/investigation_submit_payload_model.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_submit_result.dart';

class ApiInvestigationDataSource implements InvestigationDataSource {
  ApiInvestigationDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<InvestigationSubmitResult> update(InvestigationDetails details) async {
    try {
      final body = InvestigationSubmitPayloadModel.fromDomain(details).toUpdateJson();
      final formData = await _formDataBuilder.fromMap(body);
      final response = await _client.dio.post<Map<String, dynamic>>('/api/investigation/update', data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Failed to update investigation.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Failed to update investigation.');

      return InvestigationSubmitResult(investigationNo: details.investigationNo);
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to update investigation.');
    }
  }

  @override
  Future<void> uploadPhoto({required String investigationNo, required int sequence, required Uint8List bytes}) async {
    try {
      final body = <String, dynamic>{
        'investigation_no': investigationNo,
        'process': 'update',
        'images': [
          {'type': '', 'seq': sequence, 'file': bytes},
        ],
      };
      final formData = await _formDataBuilder.fromMap(body);
      final response = await _client.dio.post<Map<String, dynamic>>('/api/investigation/create-photo', data: formData);

      final payload = response.data;
      if (payload == null) return;

      ensureApiSuccess(payload, fallbackMessage: 'Failed to upload photo.');
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to upload photo.');
    }
  }
}

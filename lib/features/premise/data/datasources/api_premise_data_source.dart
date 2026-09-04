import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/models/premise_submit_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';

import 'premise_data_source.dart';

class ApiPremiseDataSource implements PremiseDataSource {
  ApiPremiseDataSource({FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final FormDataBuilder _formDataBuilder;

  @override
  Future<PremiseSubmitResult> create(PremiseForm form) async {
    return _submit(
      endpoint: '/api/premiseCensus/create',
      body: PremiseSubmitPayloadModel.fromDomain(form).toCreateJson(),
      pendingImageUploads: form.censusImages.where((image) => image.isLocalOnly).length,
    );
  }

  @override
  Future<PremiseSubmitResult> update(PremiseForm form) async {
    return _submit(
      endpoint: '/api/premiseCensus/update',
      body: PremiseSubmitPayloadModel.fromDomain(form).toUpdateJson(),
      pendingImageUploads: form.censusImages.where((image) => image.isLocalOnly).length,
    );
  }

  @override
  Future<void> uploadImage({
    required String visitNo,
    required String localPath,
    String? typeCode,
    int? seq,
    String process = 'create',
    void Function(double progress)? onProgress,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw ApiResponseException('Image file not found: $localPath');
    }

    final bytes = await file.readAsBytes();
    final body = <String, dynamic>{
      'visit_no': visitNo,
      'process': process,
      'images': <Map<String, dynamic>>[
        {'type': typeCode ?? PremiseCensusImageDefaults.typeCode, 'seq': seq ?? 1, 'file': bytes},
      ],
    };

    try {
      final formData = await _formDataBuilder.fromMap(body);
      final response = await DioClient.instance.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/create-photo',
        data: formData,
        onSendProgress: onProgress == null
            ? null
            : (sent, total) {
                if (total <= 0) return;
                onProgress(sent / total);
              },
      );

      final payload = response.data;
      if (payload == null) return;

      ensureApiSuccess(payload, fallbackMessage: 'Failed to upload image.');
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to upload image.');
    }
  }

  @override
  Future<void> deletePhoto({required String imageId}) async {
    try {
      final formData = await _formDataBuilder.fromMap({'image_id': imageId});
      final response = await DioClient.instance.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/delete-photo',
        data: formData,
      );

      final payload = response.data;
      if (payload == null) return;

      ensureApiSuccess(payload, fallbackMessage: 'Failed to delete photo.');
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to delete photo.');
    }
  }

  Future<PremiseSubmitResult> _submit({
    required String endpoint,
    required Map<String, dynamic> body,
    required int pendingImageUploads,
  }) async {
    try {
      // Unlike `create-photo`/`delete-photo`, this endpoint carries no files
      // — send it as plain JSON rather than flattening through
      // [FormDataBuilder]'s multipart bracket notation. Classic
      // multipart/form-data has no way to represent a genuinely empty array
      // (`business_activities: []`), which Laravel needs to tell "clear
      // every row" apart from "field not sent, leave rows alone"; JSON does.
      final response = await DioClient.instance.dio.post<Map<String, dynamic>>(endpoint, data: body);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Failed to submit premise census.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Failed to submit premise census.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Failed to submit premise census.');
      }

      final visitNo = data['visit_no']?.toString();
      if (visitNo == null || visitNo.isEmpty) {
        throw const ApiResponseException('Failed to submit premise census.');
      }

      return PremiseSubmitResult(
        visitNo: visitNo,
        updatedAt: data['updated_at']?.toString(),
        pendingImageUploads: pendingImageUploads,
      );
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to submit premise census.');
    }
  }
}

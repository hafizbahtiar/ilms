import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/billboard/data/models/billboard_photo_upload_request.dart';
import 'package:ilms/features/billboard/data/models/billboard_submit_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_submit_result.dart';
import 'package:ilms/shared/models/general_model.dart';

import 'billboard_data_source.dart';

class ApiBillboardDataSource implements BillboardDataSource {
  ApiBillboardDataSource({FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final FormDataBuilder _formDataBuilder;

  @override
  Future<BillboardSubmitResult> create(BillboardForm form) async {
    return _submit(
      endpoint: '/api/billboardCensus/create',
      body: BillboardSubmitPayloadModel.fromDomain(form).toCreateJson(),
      pendingImageUploads: form.photos.where((photo) => photo.isLocalOnly).length,
    );
  }

  @override
  Future<BillboardSubmitResult> update(BillboardForm form) async {
    return _submit(
      endpoint: '/api/billboardCensus/update',
      body: BillboardSubmitPayloadModel.fromDomain(form).toUpdateJson(),
      pendingImageUploads: form.photos.where((photo) => photo.isLocalOnly).length,
    );
  }

  @override
  Future<void> uploadPhoto({
    required String billboardNo,
    required String localPath,
    String process = 'create',
    int seq = 1,
    void Function(double progress)? onProgress,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw ApiResponseException('Photo file not found: $localPath');
    }

    final bytes = await file.readAsBytes();
    final body = BillboardPhotoUploadRequest.toMap(billboardNo: billboardNo, process: process, seq: seq, file: bytes);

    try {
      final formData = await _formDataBuilder.fromMap(body);
      final response = await DioClient.instance.dio.post<Map<String, dynamic>>(
        '/api/billboardCensus/create-photo',
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

      ensureApiSuccess(payload, fallbackMessage: 'Failed to upload photo.');
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to upload photo.');
    }
  }

  @override
  Future<void> deletePhoto({required String photoId}) async {
    try {
      final formData = await _formDataBuilder.fromMap({'photo_id': photoId});
      final response = await DioClient.instance.dio.post<Map<String, dynamic>>(
        '/api/billboardCensus/delete-photo',
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

  @override
  Future<List<GeneralModel>> fetchRemarkOptions() async {
    try {
      final payload = await DioClient.instance.get<Map<String, dynamic>>('/api/billboardCensus/remarkOptions');
      final message = payload['message'];
      final options = message is Map ? message['options'] as List? : null;
      return options
              ?.map((item) {
                if (item is! Map) return null;
                final map = Map<String, dynamic>.from(item);
                return GeneralModel(code: map['code']?.toString(), desc: map['label']?.toString());
              })
              .whereType<GeneralModel>()
              .toList(growable: false) ??
          const [];
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to load remark options.');
    }
  }

  Future<BillboardSubmitResult> _submit({
    required String endpoint,
    required Map<String, dynamic> body,
    required int pendingImageUploads,
  }) async {
    try {
      final formData = await _formDataBuilder.fromMap(body);
      final response = await DioClient.instance.dio.post<Map<String, dynamic>>(endpoint, data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Failed to submit billboard census.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Failed to submit billboard census.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Failed to submit billboard census.');
      }

      final billboardNo = data['billboard_no']?.toString();
      if (billboardNo == null || billboardNo.isEmpty) {
        throw const ApiResponseException('Failed to submit billboard census.');
      }

      return BillboardSubmitResult(
        billboardNo: billboardNo,
        updatedAt: (data['updated_at'] ?? data['billboard_date'])?.toString(),
        pendingImageUploads: pendingImageUploads,
      );
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Failed to submit billboard census.');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_detail_remote_data_source.dart';
import 'package:ilms/features/billboard/data/mappers/billboard_form_mapper.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';

class ApiBillboardDetailRemoteDataSource implements BillboardDetailRemoteDataSource {
  ApiBillboardDetailRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<BillboardForm> getDetail(String billboardNo) async {
    try {
      final formData = await _formDataBuilder.fromMap({'billboard_no': billboardNo});
      final response = await _client.dio.post<Map<String, dynamic>>('/api/billboardCensus/detail', data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Billboard detail not found.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Billboard detail not found.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Billboard detail not found.');
      }

      return BillboardFormMapper.fromApiDetail(Map<String, dynamic>.from(data));
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Billboard detail not found.');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/investigation/data/datasources/investigation_detail_remote_data_source.dart';
import 'package:ilms/features/investigation/data/mappers/investigation_detail_mapper.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';

class ApiInvestigationDetailRemoteDataSource implements InvestigationDetailRemoteDataSource {
  ApiInvestigationDetailRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<InvestigationDetails> getDetail(String investigationNo) async {
    try {
      final formData = await _formDataBuilder.fromMap({'investigation_no': investigationNo});
      final response = await _client.dio.post<Map<String, dynamic>>('/api/investigation/detail', data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Investigation detail not found.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Investigation detail not found.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Investigation detail not found.');
      }

      return InvestigationDetailMapper.fromApiDetail(Map<String, dynamic>.from(data));
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Investigation detail not found.');
    }
  }
}

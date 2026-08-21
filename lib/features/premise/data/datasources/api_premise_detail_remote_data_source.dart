import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/datasources/premise_detail_remote_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_detail_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_detail_record.dart';

class ApiPremiseDetailRemoteDataSource implements PremiseDetailRemoteDataSource {
  ApiPremiseDetailRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<PremiseDraftPayloadModel> getDetail(String visitNo) async {
    final data = await _fetchRaw(visitNo);
    return PremiseDetailMapper.fromApiDetail(data);
  }

  @override
  Future<PremiseDetailRecord> getDetailRecord(String visitNo) async {
    final data = await _fetchRaw(visitNo);
    return PremiseDetailMapper.toDetailRecord(data, visitNo: visitNo);
  }

  Future<Map<String, dynamic>> _fetchRaw(String visitNo) async {
    try {
      final formData = await _formDataBuilder.fromMap({'visit_no': visitNo});
      final response = await _client.dio.post<Map<String, dynamic>>('/api/premiseCensus/detail', data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Premise detail not found.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Premise detail not found.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Premise detail not found.');
      }

      return Map<String, dynamic>.from(data);
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Premise detail not found.');
    }
  }
}

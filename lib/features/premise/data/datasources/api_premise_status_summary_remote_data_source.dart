import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/datasources/premise_status_summary_remote_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_status_summary_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_status_summary_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';

class ApiPremiseStatusSummaryRemoteDataSource implements PremiseStatusSummaryRemoteDataSource {
  ApiPremiseStatusSummaryRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<PremiseStatusSummary> getStatusSummary({required String dateFrom, required String dateTo}) async {
    try {
      final formData = await _formDataBuilder.fromMap({'date_from': dateFrom, 'date_to': dateTo});
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/statusSummary',
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Premise status summary not found.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Premise status summary not found.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Premise status summary not found.');
      }

      final model = PremiseStatusSummaryModel.fromJson(Map<String, dynamic>.from(data));
      return PremiseStatusSummaryMapper.fromModel(model);
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Premise status summary not found.');
    }
  }
}

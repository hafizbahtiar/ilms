import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_status_summary_remote_data_source.dart';
import 'package:ilms/features/billboard/data/mappers/billboard_status_summary_mapper.dart';
import 'package:ilms/features/billboard/data/models/billboard_status_summary_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_status_summary.dart';

class ApiBillboardStatusSummaryRemoteDataSource implements BillboardStatusSummaryRemoteDataSource {
  ApiBillboardStatusSummaryRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<BillboardStatusSummary> getStatusSummary({required String dateFrom, required String dateTo}) async {
    try {
      final formData = await _formDataBuilder.fromMap({'date_from': dateFrom, 'date_to': dateTo});
      final response = await _client.dio.post<Map<String, dynamic>>('/api/billboardCensus/typeSummary', data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Billboard status summary not found.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Billboard status summary not found.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Billboard status summary not found.');
      }

      final model = BillboardStatusSummaryModel.fromJson(Map<String, dynamic>.from(data));
      return BillboardStatusSummaryMapper.fromModel(model);
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Billboard status summary not found.');
    }
  }
}

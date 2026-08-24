import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/investigation/data/datasources/investigation_search_remote_data_source.dart';
import 'package:ilms/features/investigation/data/models/investigation_search_models.dart';
import 'package:ilms/shared/models/general_response_model.dart';

class ApiInvestigationSearchRemoteDataSource implements InvestigationSearchRemoteDataSource {
  ApiInvestigationSearchRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<InvestigationSearchResultDto> search({
    required InvestigationSearchFilterDto filter,
    required int page,
    int perPage = 15,
  }) async {
    try {
      final formData = await _formDataBuilder.fromMap(filter.toJson());
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/investigation/search',
        queryParameters: {'page': page, 'per_page': perPage},
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Unable to load investigation search results.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Unable to load investigation search results.');

      final rawItems = payload['data'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => InvestigationSearchRecordDto.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : <InvestigationSearchRecordDto>[];

      final pagination = Pagination.fromJson(
        payload['pagination'] is Map ? Map<String, dynamic>.from(payload['pagination'] as Map) : {},
      );
      final currentPage = pagination.currentPage ?? page;
      final hasNextPage = pagination.nextPageUrl != null && pagination.nextPageUrl.toString().trim().isNotEmpty;

      return InvestigationSearchResultDto(
        items: items,
        nextPage: hasNextPage ? currentPage + 1 : currentPage,
        hasNextPage: hasNextPage,
      );
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Unable to load investigation search results.');
    }
  }
}

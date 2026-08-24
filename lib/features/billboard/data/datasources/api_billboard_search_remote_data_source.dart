import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_search_remote_data_source.dart';
import 'package:ilms/features/billboard/data/models/billboard_search_models.dart';
import 'package:ilms/shared/models/general_response_model.dart';

class ApiBillboardSearchRemoteDataSource implements BillboardSearchRemoteDataSource {
  ApiBillboardSearchRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<BillboardSearchResultDto> search({
    required BillboardSearchFilterDto filter,
    required int page,
    int perPage = 15,
  }) async {
    try {
      final formData = await _formDataBuilder.fromMap(filter.toJson());
      // page MUST reach the backend as a query param — sent as the body it
      // is ignored and the server returns page 1 every time (see legacy
      // `BillboardRepo.searchBillboards`).
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/billboardCensus/search',
        queryParameters: {'page': page, 'per_page': perPage},
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Unable to load billboard search results.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Unable to load billboard search results.');

      final rawItems = payload['data'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => BillboardSearchRecordDto.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : <BillboardSearchRecordDto>[];

      final pagination = Pagination.fromJson(
        payload['pagination'] is Map ? Map<String, dynamic>.from(payload['pagination'] as Map) : {},
      );
      final currentPage = pagination.currentPage ?? page;
      final hasNextPage = pagination.nextPageUrl != null && pagination.nextPageUrl.toString().trim().isNotEmpty;

      return BillboardSearchResultDto(
        items: items,
        nextPage: hasNextPage ? currentPage + 1 : currentPage,
        hasNextPage: hasNextPage,
      );
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Unable to load billboard search results.');
    }
  }
}

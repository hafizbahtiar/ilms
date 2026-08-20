import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/datasources/premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_detail_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_check.dart';
import 'package:ilms/shared/models/general_response_model.dart';

class ApiPremiseDuplicateRemoteDataSource implements PremiseDuplicateRemoteDataSource {
  ApiPremiseDuplicateRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
      : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<PremiseDuplicateCheck> checkCanDuplicate(String visitNo) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/checkDuplicatePhase',
        data: {'visit_no': visitNo},
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Unable to verify duplicate eligibility.');
      }

      final data = payload['data'];
      final isCurrentPhase = data is Map ? data['is_current_phase'] as bool? : null;
      final canDuplicate = (isCurrentPhase ?? true) == false;

      return PremiseDuplicateCheck(
        canDuplicate: canDuplicate,
        message: payload['message']?.toString(),
      );
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(
        extractDioErrorMessage(error) ?? 'Unable to verify duplicate eligibility.',
      );
    }
  }

  @override
  Future<PremiseDraftPayloadModel> loadDetail(String visitNo) async {
    try {
      final formData = await _formDataBuilder.fromMap({'visit_no': visitNo});
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/detail',
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Premise detail not found.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Premise detail not found.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('Premise detail not found.');
      }

      return PremiseDetailMapper.fromApiDetailForDuplicate(Map<String, dynamic>.from(data));
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Premise detail not found.');
    }
  }

  @override
  Future<PremiseDuplicateResultDto> searchPreviousPhase({
    required PremiseDuplicateFilterDto filter,
    required int page,
    int perPage = 15,
  }) async {
    try {
      final formData = await _formDataBuilder.fromMap(filter.toJson());
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/searchPrevPhase',
        queryParameters: {'page': page, 'per_page': perPage},
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('Unable to load duplicate search results.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'Unable to load duplicate search results.');

      final rawItems = payload['data'];
      final items = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((item) => PremiseDuplicateRecordDto.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <PremiseDuplicateRecordDto>[];

      final pagination = Pagination.fromJson(
        payload['pagination'] is Map ? Map<String, dynamic>.from(payload['pagination'] as Map) : {},
      );
      final currentPage = pagination.currentPage ?? page;
      final hasNextPage =
          pagination.nextPageUrl != null && pagination.nextPageUrl.toString().trim().isNotEmpty;

      return PremiseDuplicateResultDto(
        items: items,
        nextPage: hasNextPage ? currentPage + 1 : currentPage,
        hasNextPage: hasNextPage,
      );
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(
        extractDioErrorMessage(error) ?? 'Unable to load duplicate search results.',
      );
    }
  }
}

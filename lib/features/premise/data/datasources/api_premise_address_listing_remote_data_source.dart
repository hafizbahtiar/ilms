import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/network_exception.dart';
import 'package:ilms/features/premise/data/datasources/premise_address_listing_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_address_listing_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_address_filter.dart';

class ApiPremiseAddressListingRemoteDataSource implements PremiseAddressListingRemoteDataSource {
  ApiPremiseAddressListingRemoteDataSource(this._client);

  final DioClient _client;

  @override
  Future<PremiseAddressListingPageModel> search(PremiseAddressFilter filter) async {
    try {
      final payload = await _client.get<Map<String, dynamic>>('/api/listPremiseAddress', query: filter.toQuery());

      ensureApiSuccess(payload, fallbackMessage: 'Unable to load premise addresses.');

      final model = PremiseAddressListingResponseModel.fromJson(payload);
      final pagination = model.pagination;
      final currentPage = pagination?.currentPage ?? filter.page;
      final hasNextPage = pagination?.nextPageUrl != null && pagination!.nextPageUrl.toString().trim().isNotEmpty;

      return PremiseAddressListingPageModel(
        items: (model.data ?? const []).map((item) => item.toDomain()).toList(),
        hasNextPage: hasNextPage,
        nextPage: hasNextPage ? currentPage + 1 : currentPage,
      );
    } on ApiResponseException {
      rethrow;
    } on NetworkException catch (error) {
      throw ApiResponseException(error.message);
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'Unable to load premise addresses.');
    }
  }
}

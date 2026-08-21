import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/datasources/premise_license_qr_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_license_qr_model.dart';

class ApiPremiseLicenseQrRemoteDataSource implements PremiseLicenseQrRemoteDataSource {
  ApiPremiseLicenseQrRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<PremiseLicenseQrModel> getByLink(String link) async {
    try {
      final formData = await _formDataBuilder.fromMap({'link': link});
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/api/premiseCensus/licenseQrLink',
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('License data not found for this QR code.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'License data not found for this QR code.');

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('License data not found for this QR code.');
      }

      return PremiseLicenseQrModel.fromJson(Map<String, dynamic>.from(data));
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'License data not found for this QR code.');
    }
  }
}

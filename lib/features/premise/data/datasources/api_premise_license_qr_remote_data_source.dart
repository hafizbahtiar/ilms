import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/datasources/premise_license_qr_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_license_qr_model.dart';

const _licenseQrKnownDataKeys = {
  'license_category',
  'license_holder_name',
  'license_file_no',
  'license_status',
  'premise_address',
  'company_registration_no',
  'license_grade',
  'license_date_from',
  'license_date_to',
};

class ApiPremiseLicenseQrRemoteDataSource implements PremiseLicenseQrRemoteDataSource {
  ApiPremiseLicenseQrRemoteDataSource(this._client, {FormDataBuilder? formDataBuilder})
    : _formDataBuilder = formDataBuilder ?? const FormDataBuilder();

  final DioClient _client;
  final FormDataBuilder _formDataBuilder;

  @override
  Future<PremiseLicenseQrModel> getByLink(String link) async {
    try {
      final formData = await _formDataBuilder.fromMap({'link': link});
      final response = await _client.dio.post<Map<String, dynamic>>('/api/premiseCensus/licenseQrLink', data: formData);

      final payload = response.data;
      if (payload == null) {
        throw const ApiResponseException('License data not found for this QR code.');
      }

      ensureApiSuccess(payload, fallbackMessage: 'License data not found for this QR code.');

      _logLicenseQrResponse(payload);

      final data = payload['data'];
      if (data is! Map) {
        throw const ApiResponseException('License data not found for this QR code.');
      }

      final dataMap = Map<String, dynamic>.from(data);
      _logLicenseQrData(dataMap);

      return PremiseLicenseQrModel.fromJson(dataMap);
    } on ApiResponseException {
      rethrow;
    } on DioException catch (error) {
      throw ApiResponseException(extractDioErrorMessage(error) ?? 'License data not found for this QR code.');
    }
  }

  void _logLicenseQrResponse(Map<String, dynamic> payload) {
    dev.log('licenseQrLink full response: ${_safeJson(payload)}', name: 'PremiseLicenseQr');
  }

  void _logLicenseQrData(Map<String, dynamic> data) {
    dev.log('licenseQrLink data: ${_safeJson(data)}', name: 'PremiseLicenseQr');

    final unmapped = data.keys.where((key) => !_licenseQrKnownDataKeys.contains(key)).toList();
    if (unmapped.isEmpty) return;

    final extras = <String, dynamic>{for (final key in unmapped) key: data[key]};
    dev.log('licenseQrLink unmapped fields: ${_safeJson(extras)}', name: 'PremiseLicenseQr');
  }

  String _safeJson(Object? value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }
}

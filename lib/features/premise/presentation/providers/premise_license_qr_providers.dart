import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_license_qr_remote_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_license_qr_remote_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_license_qr_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_license_qr_repository.dart';

final premiseLicenseQrRemoteDataSourceProvider = Provider<PremiseLicenseQrRemoteDataSource>((ref) {
  return ApiPremiseLicenseQrRemoteDataSource(DioClient.instance);
});

final premiseLicenseQrRepositoryProvider = Provider<PremiseLicenseQrRepository>((ref) {
  return PremiseLicenseQrRepositoryImpl(ref.read(premiseLicenseQrRemoteDataSourceProvider));
});

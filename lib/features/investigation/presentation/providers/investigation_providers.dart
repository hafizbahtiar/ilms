import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/investigation/data/datasources/api_investigation_data_source.dart';
import 'package:ilms/features/investigation/data/datasources/api_investigation_detail_remote_data_source.dart';
import 'package:ilms/features/investigation/data/datasources/investigation_data_source.dart';
import 'package:ilms/features/investigation/data/datasources/investigation_detail_remote_data_source.dart';
import 'package:ilms/features/investigation/data/repositories/investigation_detail_repository_impl.dart';
import 'package:ilms/features/investigation/data/repositories/investigation_repository_impl.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_detail_repository.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_repository.dart';

final investigationDataSourceProvider = Provider<InvestigationDataSource>((ref) {
  return ApiInvestigationDataSource(DioClient.instance);
});

final investigationRepositoryProvider = Provider<InvestigationRepository>((ref) {
  return InvestigationRepositoryImpl(ref.read(investigationDataSourceProvider));
});

final investigationDetailRemoteDataSourceProvider = Provider<InvestigationDetailRemoteDataSource>((ref) {
  return ApiInvestigationDetailRemoteDataSource(DioClient.instance);
});

final investigationDetailRepositoryProvider = Provider<InvestigationDetailRepository>((ref) {
  return InvestigationDetailRepositoryImpl(ref.read(investigationDetailRemoteDataSourceProvider));
});

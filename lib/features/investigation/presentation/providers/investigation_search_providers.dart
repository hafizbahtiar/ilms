import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/investigation/data/datasources/api_investigation_search_remote_data_source.dart';
import 'package:ilms/features/investigation/data/datasources/investigation_search_remote_data_source.dart';
import 'package:ilms/features/investigation/data/repositories/investigation_search_repository_impl.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_search_repository.dart';

final investigationSearchRemoteDataSourceProvider = Provider<InvestigationSearchRemoteDataSource>((ref) {
  return ApiInvestigationSearchRemoteDataSource(DioClient.instance);
});

final investigationSearchRepositoryProvider = Provider<InvestigationSearchRepository>((ref) {
  return InvestigationSearchRepositoryImpl(ref.read(investigationSearchRemoteDataSourceProvider));
});

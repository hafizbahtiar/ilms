import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_search_remote_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_search_remote_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_search_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_search_repository.dart';

final premiseSearchRemoteDataSourceProvider = Provider<PremiseSearchRemoteDataSource>((ref) {
  return ApiPremiseSearchRemoteDataSource(ref.watch(dioClientProvider));
});

final premiseSearchRepositoryProvider = Provider<PremiseSearchRepository>((ref) {
  return PremiseSearchRepositoryImpl(ref.watch(premiseSearchRemoteDataSourceProvider));
});

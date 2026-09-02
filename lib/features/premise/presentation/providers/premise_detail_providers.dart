import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_detail_remote_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_detail_remote_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_detail_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_detail_repository.dart';

final premiseDetailRemoteDataSourceProvider = Provider<PremiseDetailRemoteDataSource>((ref) {
  return ApiPremiseDetailRemoteDataSource(ref.watch(dioClientProvider));
});

final premiseDetailRepositoryProvider = Provider<PremiseDetailRepository>((ref) {
  return PremiseDetailRepositoryImpl(ref.watch(premiseDetailRemoteDataSourceProvider));
});

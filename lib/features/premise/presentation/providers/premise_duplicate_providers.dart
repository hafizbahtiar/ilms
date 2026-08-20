import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_duplicate_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_duplicate_repository.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';

final premiseDuplicateRemoteDataSourceProvider = Provider<PremiseDuplicateRemoteDataSource>((ref) {
  return ApiPremiseDuplicateRemoteDataSource(DioClient.instance);
});

final premiseDuplicateRepositoryProvider = Provider<PremiseDuplicateRepository>((ref) {
  return PremiseDuplicateRepositoryImpl(
    ref.read(premiseDuplicateRemoteDataSourceProvider),
    ref.read(premiseDraftRepositoryProvider),
  );
});

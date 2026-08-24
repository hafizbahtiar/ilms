import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/billboard/data/datasources/api_billboard_search_remote_data_source.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_search_remote_data_source.dart';
import 'package:ilms/features/billboard/data/repositories/billboard_search_repository_impl.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_search_repository.dart';

final billboardSearchRemoteDataSourceProvider = Provider<BillboardSearchRemoteDataSource>((ref) {
  return ApiBillboardSearchRemoteDataSource(DioClient.instance);
});

final billboardSearchRepositoryProvider = Provider<BillboardSearchRepository>((ref) {
  return BillboardSearchRepositoryImpl(ref.read(billboardSearchRemoteDataSourceProvider));
});

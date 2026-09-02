import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/billboard/data/datasources/api_billboard_data_source.dart';
import 'package:ilms/features/billboard/data/datasources/api_billboard_detail_remote_data_source.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_data_source.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_detail_remote_data_source.dart';
import 'package:ilms/features/billboard/data/repositories/billboard_detail_repository_impl.dart';
import 'package:ilms/features/billboard/data/repositories/billboard_repository_impl.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_detail_repository.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_repository.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';

final billboardDataSourceProvider = Provider<BillboardDataSource>((ref) {
  return ApiBillboardDataSource();
});

final billboardRepositoryProvider = Provider<BillboardRepository>((ref) {
  return BillboardRepositoryImpl(ref.read(billboardDataSourceProvider));
});

final billboardDetailRemoteDataSourceProvider = Provider<BillboardDetailRemoteDataSource>((ref) {
  return ApiBillboardDetailRemoteDataSource(ref.watch(dioClientProvider));
});

final billboardDetailRepositoryProvider = Provider<BillboardDetailRepository>((ref) {
  return BillboardDetailRepositoryImpl(ref.watch(billboardDetailRemoteDataSourceProvider));
});

final billboardPhasesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getPhasesByBillboard();
});

final billboardTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getBillboardTypes();
});

final billboardAssetOwnersProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getAssetOwnerTypes();
});

final billboardParliamentsProvider = generalParliamentsProvider;
final billboardAreasByParliamentProvider = generalAreasByParliamentProvider;

final billboardRemarksProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(billboardDataSourceProvider).fetchRemarkOptions();
});

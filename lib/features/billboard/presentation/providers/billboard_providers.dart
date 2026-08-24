import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client.dart';
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
  return ApiBillboardDetailRemoteDataSource(DioClient.instance);
});

final billboardDetailRepositoryProvider = Provider<BillboardDetailRepository>((ref) {
  return BillboardDetailRepositoryImpl(ref.read(billboardDetailRemoteDataSourceProvider));
});

// Billboard re-exports general lookup providers for section widgets, exactly
// like premise_providers.dart does — no billboard-specific lookup datasource.
final billboardPhasesProvider = generalPhasesProvider;
final billboardParliamentsProvider = generalParliamentsProvider;
final billboardAreasByParliamentProvider = generalAreasByParliamentProvider;
final billboardRemarksProvider = generalRemarksProvider;

/// TODO: `lib/shared/lookups/` has no billboard-type lookup yet (legacy
/// endpoint unknown at the time this presentation layer was built). Using a
/// hardcoded placeholder list so the picker is functional; replace with a
/// real `GeneralLookupRepository.getBillboardTypes()`-style call once the
/// endpoint is confirmed.
final billboardTypesProvider = FutureProvider<List<GeneralModel>>((ref) async {
  return const [
    GeneralModel(code: 'BUNTING', desc: 'Bunting'),
    GeneralModel(code: 'GANTRY', desc: 'Gantry'),
    GeneralModel(code: 'BILLBOARD', desc: 'Billboard'),
    GeneralModel(code: 'SIGNBOARD', desc: 'Signboard'),
    GeneralModel(code: 'LED', desc: 'LED Screen'),
  ];
});

/// TODO: `lib/shared/lookups/` has no asset-owner lookup yet. Using a
/// hardcoded placeholder list so the picker is functional; replace with a
/// real lookup call once the endpoint is confirmed.
final billboardAssetOwnersProvider = FutureProvider<List<GeneralModel>>((ref) async {
  return const [
    GeneralModel(code: 'DBKL', desc: 'Dewan Bandaraya Kuala Lumpur'),
    GeneralModel(code: 'PRIVATE', desc: 'Private Owner'),
    GeneralModel(code: 'JKR', desc: 'Jabatan Kerja Raya'),
    GeneralModel(code: 'TNB', desc: 'Tenaga Nasional Berhad'),
  ];
});

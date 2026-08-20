import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/shared/lookups/data/datasources/api_general_lookup_data_source.dart';
import 'package:ilms/shared/lookups/data/datasources/general_lookup_data_source.dart';
import 'package:ilms/shared/lookups/data/repositories/general_lookup_repository_impl.dart';
import 'package:ilms/shared/lookups/domain/general_lookup_repository.dart';
import 'package:ilms/shared/models/general_model.dart';

export 'package:ilms/shared/lookups/lookup_labels.dart';

final generalLookupDataSourceProvider = Provider<GeneralLookupDataSource>((ref) {
  return ApiGeneralLookupDataSource(DioClient.instance);
});

final generalLookupRepositoryProvider = Provider<GeneralLookupRepository>((ref) {
  return GeneralLookupRepositoryImpl(
    ref.read(generalLookupDataSourceProvider),
    AppDatabase.instance,
  );
});

/// Refreshes all lookup caches and invalidates in-memory providers.
Future<void> refreshAllGeneralLookups(WidgetRef ref) async {
  final repository = ref.read(generalLookupRepositoryProvider);
  await repository.clearAllCaches();
  ref.invalidate(generalStatesProvider);
  ref.invalidate(generalBusinessTypesProvider);
  ref.invalidate(generalPremiseTypesProvider);
  ref.invalidate(generalVisitBusinessTypesProvider);
  ref.invalidate(generalVisitStatusesProvider);
  ref.invalidate(generalImageTypesProvider);
  ref.invalidate(generalRemarksProvider);
  ref.invalidate(generalBusinessActivityStatusesProvider);
  ref.invalidate(generalBusinessLicenseStatusesProvider);
  ref.invalidate(generalPhasesProvider);
  ref.invalidate(generalYesNoProvider);
  ref.invalidate(generalPostcodesProvider);
  ref.invalidate(generalAreasProvider);
  ref.invalidate(generalParliamentsProvider);
  ref.invalidate(generalAreasByParliamentProvider);
  ref.invalidate(generalStreetsProvider);
  ref.invalidate(generalBuildingsProvider);
  ref.invalidate(generalUnitsProvider);
}

final generalStatesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getStates();
});

final generalPostcodesProvider = FutureProvider.family<List<GeneralModel>, String?>((ref, stateCode) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getPostcodes(stateCode: stateCode);
});

final generalAreasProvider = FutureProvider.family<List<GeneralModel>, GeneralAreaFilter>((ref, filter) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getAreas(stateCode: filter.stateCode, postcode: filter.postcode);
});

final generalParliamentsProvider = FutureProvider.family<List<GeneralModel>, String?>((ref, stateCode) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getParliaments(stateCode: stateCode);
});

final generalAreasByParliamentProvider = FutureProvider.family<List<GeneralModel>, String>((ref, parliamentCode) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getAreasByParliament(parliamentCode);
});

final generalStreetsProvider = FutureProvider.family<List<GeneralModel>, String>((ref, areaCode) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getStreets(areaCode);
});

final generalBuildingsProvider = FutureProvider.family<List<GeneralModel>, String>((ref, streetCode) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getBuildings(streetCode);
});

class GeneralUnitFilter {
  const GeneralUnitFilter({this.buildingCode, this.streetCode});

  final String? buildingCode;
  final String? streetCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralUnitFilter && other.buildingCode == buildingCode && other.streetCode == streetCode;

  @override
  int get hashCode => Object.hash(buildingCode, streetCode);
}

final generalUnitsProvider = FutureProvider.family<List<GeneralModel>, GeneralUnitFilter>((ref, filter) {
  ref.keepAlive();
  return ref
      .read(generalLookupRepositoryProvider)
      .getUnits(buildingCode: filter.buildingCode, streetCode: filter.streetCode);
});

final generalBusinessTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getBusinessTypes();
});

final generalPremiseTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getPremiseTypes();
});

final generalVisitBusinessTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getVisitBusinessTypes();
});

final generalVisitStatusesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getVisitStatuses();
});

final generalImageTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getImageTypes();
});

final generalRemarksProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getRemarks();
});

final generalBusinessActivityStatusesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getBusinessActivityStatuses();
});

final generalBusinessLicenseStatusesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getBusinessLicenseStatuses();
});

final generalPhasesProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getPhases();
});

final generalYesNoProvider = FutureProvider<List<GeneralModel>>((ref) {
  ref.keepAlive();
  return ref.read(generalLookupRepositoryProvider).getYesNo();
});

class GeneralAreaFilter {
  const GeneralAreaFilter({this.stateCode, this.postcode});

  final String? stateCode;
  final String? postcode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralAreaFilter && other.stateCode == stateCode && other.postcode == postcode;

  @override
  int get hashCode => Object.hash(stateCode, postcode);
}

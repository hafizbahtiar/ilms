import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/shared/lookups/data/datasources/general_lookup_data_source.dart';
import 'package:ilms/shared/lookups/data/general_lookup_cache_keys.dart';
import 'package:ilms/shared/lookups/domain/general_lookup_repository.dart';
import 'package:ilms/shared/models/general_model.dart';

class GeneralLookupRepositoryImpl implements GeneralLookupRepository {
  GeneralLookupRepositoryImpl(this._dataSource, this._database);

  final GeneralLookupDataSource _dataSource;
  final AppDatabase _database;

  @override
  Future<List<GeneralModel>> getStates() {
    return _readOrFetch(GeneralLookupCacheKeys.states(), _dataSource.fetchStates);
  }

  @override
  Future<List<GeneralModel>> getPostcodes({String? stateCode}) {
    return _readOrFetch(
      GeneralLookupCacheKeys.postcodes(stateCode),
      () => _dataSource.fetchPostcodes(stateCode: stateCode),
    );
  }

  @override
  Future<List<GeneralModel>> getAreas({String? stateCode, String? postcode}) {
    return _readOrFetch(
      GeneralLookupCacheKeys.areas(stateCode, postcode),
      () => _dataSource.fetchAreas(stateCode: stateCode, postcode: postcode),
    );
  }

  @override
  Future<List<GeneralModel>> getAreasByParliament(String parliamentCode) {
    return _readOrFetch(
      GeneralLookupCacheKeys.areasByParliament(parliamentCode),
      () => _dataSource.fetchAreasByParliament(parliamentCode),
    );
  }

  @override
  Future<List<GeneralModel>> getBuildings(String streetCode) {
    return _readOrFetch(
      GeneralLookupCacheKeys.buildings(streetCode),
      () => _dataSource.fetchBuildings(streetCode),
    );
  }

  @override
  Future<List<GeneralModel>> getStreets(String areaCode) {
    return _readOrFetch(
      GeneralLookupCacheKeys.streets(areaCode),
      () => _dataSource.fetchStreets(areaCode),
    );
  }

  @override
  Future<List<GeneralModel>> getUnits({String? buildingCode, String? streetCode}) {
    return _readOrFetch(
      GeneralLookupCacheKeys.units(buildingCode: buildingCode, streetCode: streetCode),
      () => _dataSource.fetchUnits(buildingCode: buildingCode, streetCode: streetCode),
    );
  }

  @override
  Future<List<GeneralModel>> getBusinessActivityStatuses() {
    return _readOrFetch(
      GeneralLookupCacheKeys.businessActivityStatuses(),
      _dataSource.fetchBusinessActivityStatuses,
    );
  }

  @override
  Future<List<GeneralModel>> getBusinessLicenseStatuses() {
    return _readOrFetch(
      GeneralLookupCacheKeys.businessLicenseStatuses(),
      _dataSource.fetchBusinessLicenseStatuses,
    );
  }

  @override
  Future<List<GeneralModel>> getBusinessTypes() {
    return _readOrFetch(GeneralLookupCacheKeys.businessTypes(), _dataSource.fetchBusinessTypes);
  }

  @override
  Future<List<GeneralModel>> getImageTypes() {
    return _readOrFetch(GeneralLookupCacheKeys.imageTypes(), _dataSource.fetchImageTypes);
  }

  @override
  Future<List<GeneralModel>> getParliaments({String? stateCode}) {
    return _readOrFetch(
      GeneralLookupCacheKeys.parliaments(stateCode),
      () => _dataSource.fetchParliaments(stateCode: stateCode),
    );
  }

  @override
  Future<List<GeneralModel>> getPhases() {
    return _readOrFetch(GeneralLookupCacheKeys.phases(), _dataSource.fetchPhases);
  }

  @override
  Future<List<GeneralModel>> getPremiseTypes() {
    return _readOrFetch(GeneralLookupCacheKeys.premiseTypes(), _dataSource.fetchPremiseTypes);
  }

  @override
  Future<List<GeneralModel>> getRemarks() {
    return _readOrFetch(GeneralLookupCacheKeys.remarks(), _dataSource.fetchRemarks);
  }

  @override
  Future<List<GeneralModel>> getVisitBusinessTypes() {
    return _readOrFetch(GeneralLookupCacheKeys.visitBusinessTypes(), _dataSource.fetchVisitBusinessTypes);
  }

  @override
  Future<List<GeneralModel>> getVisitStatuses() {
    return _readOrFetch(GeneralLookupCacheKeys.visitStatuses(), _dataSource.fetchVisitStatuses);
  }

  @override
  Future<List<GeneralModel>> getYesNo() {
    return _readOrFetch(GeneralLookupCacheKeys.yesNo(), _dataSource.getYesNo);
  }

  @override
  Future<List<GeneralModel>> refreshStates() => _refresh(GeneralLookupCacheKeys.states(), _dataSource.fetchStates);

  @override
  Future<List<GeneralModel>> refreshPostcodes({String? stateCode}) {
    return _refresh(
      GeneralLookupCacheKeys.postcodes(stateCode),
      () => _dataSource.fetchPostcodes(stateCode: stateCode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshAreas({String? stateCode, String? postcode}) {
    return _refresh(
      GeneralLookupCacheKeys.areas(stateCode, postcode),
      () => _dataSource.fetchAreas(stateCode: stateCode, postcode: postcode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshParliaments({String? stateCode}) {
    return _refresh(
      GeneralLookupCacheKeys.parliaments(stateCode),
      () => _dataSource.fetchParliaments(stateCode: stateCode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshAreasByParliament(String parliamentCode) {
    return _refresh(
      GeneralLookupCacheKeys.areasByParliament(parliamentCode),
      () => _dataSource.fetchAreasByParliament(parliamentCode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshStreets(String areaCode) {
    return _refresh(
      GeneralLookupCacheKeys.streets(areaCode),
      () => _dataSource.fetchStreets(areaCode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshBuildings(String streetCode) {
    return _refresh(
      GeneralLookupCacheKeys.buildings(streetCode),
      () => _dataSource.fetchBuildings(streetCode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshUnits({String? buildingCode, String? streetCode}) {
    return _refresh(
      GeneralLookupCacheKeys.units(buildingCode: buildingCode, streetCode: streetCode),
      () => _dataSource.fetchUnits(buildingCode: buildingCode, streetCode: streetCode),
    );
  }

  @override
  Future<List<GeneralModel>> refreshBusinessTypes() {
    return _refresh(GeneralLookupCacheKeys.businessTypes(), _dataSource.fetchBusinessTypes);
  }

  @override
  Future<List<GeneralModel>> refreshPremiseTypes() {
    return _refresh(GeneralLookupCacheKeys.premiseTypes(), _dataSource.fetchPremiseTypes);
  }

  @override
  Future<List<GeneralModel>> refreshVisitBusinessTypes() {
    return _refresh(GeneralLookupCacheKeys.visitBusinessTypes(), _dataSource.fetchVisitBusinessTypes);
  }

  @override
  Future<List<GeneralModel>> refreshVisitStatuses() {
    return _refresh(GeneralLookupCacheKeys.visitStatuses(), _dataSource.fetchVisitStatuses);
  }

  @override
  Future<List<GeneralModel>> refreshImageTypes() {
    return _refresh(GeneralLookupCacheKeys.imageTypes(), _dataSource.fetchImageTypes);
  }

  @override
  Future<List<GeneralModel>> refreshRemarks() {
    return _refresh(GeneralLookupCacheKeys.remarks(), _dataSource.fetchRemarks);
  }

  @override
  Future<List<GeneralModel>> refreshBusinessActivityStatuses() {
    return _refresh(GeneralLookupCacheKeys.businessActivityStatuses(), _dataSource.fetchBusinessActivityStatuses);
  }

  @override
  Future<List<GeneralModel>> refreshBusinessLicenseStatuses() {
    return _refresh(GeneralLookupCacheKeys.businessLicenseStatuses(), _dataSource.fetchBusinessLicenseStatuses);
  }

  @override
  Future<List<GeneralModel>> refreshPhases() {
    return _refresh(GeneralLookupCacheKeys.phases(), _dataSource.fetchPhases);
  }

  @override
  Future<List<GeneralModel>> refreshYesNo() {
    return _refresh(GeneralLookupCacheKeys.yesNo(), _dataSource.getYesNo);
  }

  @override
  Future<void> clearAllCaches() async {
    final rows = await _database.select(_database.keyValueEntries).get();
    for (final row in rows) {
      if (row.key.startsWith(GeneralLookupCacheKeys.prefix)) {
        await _database.deleteKeyValue(row.key);
      }
    }
  }

  Future<List<GeneralModel>> _readOrFetch(
    String cacheKey,
    Future<List<GeneralModel>> Function() fetch,
  ) async {
    final cached = await _readCache(cacheKey);
    if (cached != null) return cached;

    final fresh = await fetch();
    await _writeCache(cacheKey, fresh);
    return fresh;
  }

  Future<List<GeneralModel>> _refresh(
    String cacheKey,
    Future<List<GeneralModel>> Function() fetch,
  ) async {
    await _database.deleteKeyValue(cacheKey);
    final fresh = await fetch();
    await _writeCache(cacheKey, fresh);
    return fresh;
  }

  Future<List<GeneralModel>?> _readCache(String cacheKey) async {
    final raw = await _database.readKeyValue(cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return GeneralLookupCacheCodec.decode(raw);
    } catch (_) {
      await _database.deleteKeyValue(cacheKey);
      return null;
    }
  }

  Future<void> _writeCache(String cacheKey, List<GeneralModel> items) async {
    await _database.upsertKeyValue(key: cacheKey, value: GeneralLookupCacheCodec.encode(items));
  }
}

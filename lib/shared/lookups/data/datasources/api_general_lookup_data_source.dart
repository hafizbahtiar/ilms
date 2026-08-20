import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/shared/lookups/data/datasources/general_lookup_data_source.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/models/general_response_model.dart';

/// API-backed lookup data source — mirrors legacy `GeneralRepo.fetchData`.
class ApiGeneralLookupDataSource implements GeneralLookupDataSource {
  ApiGeneralLookupDataSource(this._client);

  final DioClient _client;

  static const _yesNo = <GeneralModel>[GeneralModel(code: 'Y', desc: 'Yes'), GeneralModel(code: 'N', desc: 'No')];

  @override
  Future<List<GeneralModel>> fetchStates() => _fetch('/api/listState');

  @override
  Future<List<GeneralModel>> fetchPostcodes({String? stateCode}) => _fetch('/api/listPostal');

  @override
  Future<List<GeneralModel>> fetchAreas({String? stateCode, String? postcode}) => _fetch('/api/listArea');

  @override
  Future<List<GeneralModel>> fetchParliaments({String? stateCode}) => _fetch('/api/listParliament');

  @override
  Future<List<GeneralModel>> fetchAreasByParliament(String parliamentCode) {
    return _search('/api/searchAreaByParliament', {'parliament': parliamentCode});
  }

  @override
  Future<List<GeneralModel>> fetchStreets(String areaCode) {
    return _search('/api/searchStreetByArea', {'area': areaCode});
  }

  @override
  Future<List<GeneralModel>> fetchBuildings(String streetCode) {
    return _search('/api/searchBuildingByStreet', {'street': streetCode});
  }

  @override
  Future<List<GeneralModel>> fetchUnits({String? buildingCode, String? streetCode}) {
    return _search('/api/searchUnitByBuilding', {'building': buildingCode ?? '', 'street': streetCode ?? ''});
  }

  @override
  Future<List<GeneralModel>> fetchBusinessTypes() => _fetch('/api/listBusinessType');

  @override
  Future<List<GeneralModel>> fetchPremiseTypes() => _fetch('/api/listPremiseType');

  @override
  Future<List<GeneralModel>> fetchVisitBusinessTypes() => _fetch('/api/listVisitBusinessType');

  @override
  Future<List<GeneralModel>> fetchVisitStatuses() => _fetch('/api/listVisitStatus');

  @override
  Future<List<GeneralModel>> fetchImageTypes() => _fetch('/api/listPremiseImageType');

  @override
  Future<List<GeneralModel>> fetchRemarks() => _fetch('/api/listRemark');

  @override
  Future<List<GeneralModel>> fetchBusinessActivityStatuses() => _fetch('/api/listBusinessActivityStatus');

  @override
  Future<List<GeneralModel>> fetchBusinessLicenseStatuses() => _fetch('/api/listBusinessLicenseStatus');

  @override
  Future<List<GeneralModel>> fetchPhases() => _fetch('/api/listPhase');

  @override
  Future<List<GeneralModel>> getYesNo() async => _yesNo;

  Future<List<GeneralModel>> _fetch(String endpoint) async {
    final data = await _client.get<Map<String, dynamic>>(endpoint);
    return GeneralResponseModel.fromJson(data).data ?? const [];
  }

  Future<List<GeneralModel>> _search(String endpoint, Map<String, String> params) async {
    final data = await _client.get<Map<String, dynamic>>(endpoint, query: params);
    return GeneralResponseModel.fromJson(data).data ?? const [];
  }
}

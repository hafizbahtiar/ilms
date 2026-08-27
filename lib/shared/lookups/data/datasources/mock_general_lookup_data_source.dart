import 'package:ilms/shared/lookups/data/mock/general_lookup_catalog.dart';
import 'package:ilms/shared/lookups/data/datasources/general_lookup_data_source.dart';
import 'package:ilms/shared/models/general_model.dart';

class MockGeneralLookupDataSource implements GeneralLookupDataSource {
  const MockGeneralLookupDataSource();

  @override
  Future<List<GeneralModel>> fetchStates() async => GeneralLookupCatalog.states;

  @override
  Future<List<GeneralModel>> fetchPostcodes({String? stateCode}) async {
    return GeneralLookupCatalog.filterPostcodes(stateCode: stateCode);
  }

  @override
  Future<List<GeneralModel>> fetchAreas({String? stateCode, String? postcode}) async {
    return GeneralLookupCatalog.filterAreas(stateCode: stateCode, postcode: postcode);
  }

  @override
  Future<List<GeneralModel>> fetchParliaments({String? stateCode}) async {
    return GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.parliaments, stateCode);
  }

  @override
  Future<List<GeneralModel>> fetchAreasByParliament(String parliamentCode) async {
    return GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.areasByParliament, parliamentCode);
  }

  @override
  Future<List<GeneralModel>> fetchStreets(String areaCode, {String? search}) async {
    return GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.streets, areaCode);
  }

  @override
  Future<List<GeneralModel>> fetchBuildings(String streetCode) async {
    return GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.buildings, streetCode);
  }

  @override
  Future<List<GeneralModel>> fetchUnits({String? buildingCode, String? streetCode}) async {
    if (buildingCode != null && buildingCode.isNotEmpty) {
      return GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.units, buildingCode);
    }
    if (streetCode != null && streetCode.isNotEmpty) {
      return GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.units, streetCode);
    }
    return const [];
  }

  @override
  Future<List<GeneralModel>> fetchBusinessTypes() async => GeneralLookupCatalog.businessTypes;

  @override
  Future<List<GeneralModel>> fetchPremiseTypes() async => GeneralLookupCatalog.premiseTypes;

  @override
  Future<List<GeneralModel>> fetchVisitBusinessTypes() async => GeneralLookupCatalog.visitBusinessTypes;

  @override
  Future<List<GeneralModel>> fetchVisitStatuses() async => GeneralLookupCatalog.visitStatuses;

  @override
  Future<List<GeneralModel>> fetchImageTypes() async => GeneralLookupCatalog.imageTypes;

  @override
  Future<List<GeneralModel>> fetchRemarks() async => GeneralLookupCatalog.remarks;

  @override
  Future<List<GeneralModel>> fetchBusinessActivityStatuses() async => GeneralLookupCatalog.businessActivityStatuses;

  @override
  Future<List<GeneralModel>> fetchBusinessLicenseStatuses() async => GeneralLookupCatalog.businessLicenseStatuses;

  @override
  Future<List<GeneralModel>> fetchPhases() async => GeneralLookupCatalog.phases;

  @override
  Future<List<GeneralModel>> getYesNo() async => GeneralLookupCatalog.yesNo;
}

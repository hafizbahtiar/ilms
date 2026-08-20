import 'package:ilms/shared/models/general_model.dart';

abstract class GeneralLookupDataSource {
  Future<List<GeneralModel>> fetchStates();

  Future<List<GeneralModel>> fetchPostcodes({String? stateCode});

  Future<List<GeneralModel>> fetchAreas({String? stateCode, String? postcode});

  Future<List<GeneralModel>> fetchParliaments({String? stateCode});

  Future<List<GeneralModel>> fetchAreasByParliament(String parliamentCode);

  Future<List<GeneralModel>> fetchStreets(String areaCode);

  Future<List<GeneralModel>> fetchBuildings(String streetCode);

  Future<List<GeneralModel>> fetchUnits({String? buildingCode, String? streetCode});

  Future<List<GeneralModel>> fetchBusinessTypes();

  Future<List<GeneralModel>> fetchPremiseTypes();

  Future<List<GeneralModel>> fetchVisitBusinessTypes();

  Future<List<GeneralModel>> fetchVisitStatuses();

  Future<List<GeneralModel>> fetchImageTypes();

  Future<List<GeneralModel>> fetchRemarks();

  Future<List<GeneralModel>> fetchBusinessActivityStatuses();

  Future<List<GeneralModel>> fetchBusinessLicenseStatuses();

  Future<List<GeneralModel>> fetchPhases();

  Future<List<GeneralModel>> getYesNo();
}

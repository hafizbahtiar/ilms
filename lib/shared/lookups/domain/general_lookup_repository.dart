import 'package:ilms/shared/models/general_model.dart';

/// Shared lookup lists used across Premise, Billboard, Investigation, etc.
abstract class GeneralLookupRepository {
  Future<List<GeneralModel>> getStates();

  Future<List<GeneralModel>> getPostcodes({String? stateCode});

  Future<List<GeneralModel>> getAreas({String? stateCode, String? postcode});

  Future<List<GeneralModel>> getParliaments({String? stateCode});

  Future<List<GeneralModel>> getAreasByParliament(String parliamentCode);

  Future<List<GeneralModel>> getStreets(String areaCode);

  Future<List<GeneralModel>> getBuildings(String streetCode);

  Future<List<GeneralModel>> getUnits({String? buildingCode, String? streetCode});

  Future<List<GeneralModel>> getBusinessTypes();

  Future<List<GeneralModel>> getPremiseTypes();

  Future<List<GeneralModel>> getVisitBusinessTypes();

  Future<List<GeneralModel>> getVisitStatuses();

  Future<List<GeneralModel>> getImageTypes();

  Future<List<GeneralModel>> getRemarks();

  Future<List<GeneralModel>> getBusinessActivityStatuses();

  Future<List<GeneralModel>> getBusinessLicenseStatuses();

  Future<List<GeneralModel>> getPhases();

  Future<List<GeneralModel>> getYesNo();

  /// Clears cached entries and refetches from the remote/mock source.
  Future<List<GeneralModel>> refreshStates();

  Future<List<GeneralModel>> refreshPostcodes({String? stateCode});

  Future<List<GeneralModel>> refreshAreas({String? stateCode, String? postcode});

  Future<List<GeneralModel>> refreshParliaments({String? stateCode});

  Future<List<GeneralModel>> refreshAreasByParliament(String parliamentCode);

  Future<List<GeneralModel>> refreshStreets(String areaCode);

  Future<List<GeneralModel>> refreshBuildings(String streetCode);

  Future<List<GeneralModel>> refreshUnits({String? buildingCode, String? streetCode});

  Future<List<GeneralModel>> refreshBusinessTypes();

  Future<List<GeneralModel>> refreshPremiseTypes();

  Future<List<GeneralModel>> refreshVisitBusinessTypes();

  Future<List<GeneralModel>> refreshVisitStatuses();

  Future<List<GeneralModel>> refreshImageTypes();

  Future<List<GeneralModel>> refreshRemarks();

  Future<List<GeneralModel>> refreshBusinessActivityStatuses();

  Future<List<GeneralModel>> refreshBusinessLicenseStatuses();

  Future<List<GeneralModel>> refreshPhases();

  Future<List<GeneralModel>> refreshYesNo();

  /// Clears every cached lookup key (`lookup:*`).
  Future<void> clearAllCaches();
}

import 'package:ilms/shared/models/general_model.dart';

abstract class PremiseLookupRepository {
  Future<List<GeneralModel>> getBusinessTypes();

  Future<List<GeneralModel>> getPremiseTypes();

  Future<List<GeneralModel>> getStates();

  Future<List<GeneralModel>> getPostcodes();

  Future<List<GeneralModel>> getAreas();

  Future<List<GeneralModel>> getImageTypes();
}

import 'package:ilms/shared/models/general_model.dart';

abstract class PremiseLookupDataSource {
  Future<List<GeneralModel>> fetchBusinessTypes();

  Future<List<GeneralModel>> fetchPremiseTypes();

  Future<List<GeneralModel>> fetchStates();

  Future<List<GeneralModel>> fetchPostcodes();

  Future<List<GeneralModel>> fetchAreas();

  Future<List<GeneralModel>> fetchImageTypes();
}

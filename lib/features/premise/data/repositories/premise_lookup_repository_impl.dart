import 'package:ilms/features/premise/data/datasources/premise_lookup_data_source.dart';
import 'package:ilms/features/premise/domain/repositories/premise_lookup_repository.dart';
import 'package:ilms/shared/models/general_model.dart';

class PremiseLookupRepositoryImpl implements PremiseLookupRepository {
  PremiseLookupRepositoryImpl(this._dataSource);

  final PremiseLookupDataSource _dataSource;

  @override
  Future<List<GeneralModel>> getAreas() => _dataSource.fetchAreas();

  @override
  Future<List<GeneralModel>> getBusinessTypes() => _dataSource.fetchBusinessTypes();

  @override
  Future<List<GeneralModel>> getImageTypes() => _dataSource.fetchImageTypes();

  @override
  Future<List<GeneralModel>> getPostcodes() => _dataSource.fetchPostcodes();

  @override
  Future<List<GeneralModel>> getPremiseTypes() => _dataSource.fetchPremiseTypes();

  @override
  Future<List<GeneralModel>> getStates() => _dataSource.fetchStates();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/data/datasources/mock_premise_data_source.dart';
import 'package:ilms/features/premise/data/datasources/mock_premise_lookup_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_lookup_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_lookup_repository_impl.dart';
import 'package:ilms/features/premise/data/repositories/premise_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_lookup_repository.dart';
import 'package:ilms/features/premise/domain/repositories/premise_repository.dart';
import 'package:ilms/shared/models/general_model.dart';

final premiseDataSourceProvider = Provider<PremiseDataSource>((ref) {
  return const MockPremiseDataSource();
});

final premiseRepositoryProvider = Provider<PremiseRepository>((ref) {
  return PremiseRepositoryImpl(ref.read(premiseDataSourceProvider));
});

final premiseLookupDataSourceProvider = Provider<PremiseLookupDataSource>((ref) {
  return const MockPremiseLookupDataSource();
});

final premiseLookupRepositoryProvider = Provider<PremiseLookupRepository>((ref) {
  return PremiseLookupRepositoryImpl(ref.read(premiseLookupDataSourceProvider));
});

final premiseBusinessTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  return ref.read(premiseLookupRepositoryProvider).getBusinessTypes();
});

final premisePremiseTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  return ref.read(premiseLookupRepositoryProvider).getPremiseTypes();
});

final premiseStatesProvider = FutureProvider<List<GeneralModel>>((ref) {
  return ref.read(premiseLookupRepositoryProvider).getStates();
});

final premisePostcodesProvider = FutureProvider<List<GeneralModel>>((ref) {
  return ref.read(premiseLookupRepositoryProvider).getPostcodes();
});

final premiseAreasProvider = FutureProvider<List<GeneralModel>>((ref) {
  return ref.read(premiseLookupRepositoryProvider).getAreas();
});

final premiseImageTypesProvider = FutureProvider<List<GeneralModel>>((ref) {
  return ref.read(premiseLookupRepositoryProvider).getImageTypes();
});

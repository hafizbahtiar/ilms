import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_repository.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';

final premiseDataSourceProvider = Provider<PremiseDataSource>((ref) {
  return ApiPremiseDataSource();
});

final premiseRepositoryProvider = Provider<PremiseRepository>((ref) {
  return PremiseRepositoryImpl(ref.read(premiseDataSourceProvider));
});

// Premise re-exports general lookup providers for section widgets.
final premiseBusinessTypesProvider = generalBusinessTypesProvider;
final premisePremiseTypesProvider = generalPremiseTypesProvider;
final premiseStatesProvider = generalStatesProvider;
final premiseImageTypesProvider = generalImageTypesProvider;
final premiseParliamentsProvider = generalParliamentsProvider;
final premiseRemarksProvider = generalRemarksProvider;

final premisePostcodesProvider = FutureProvider.family<List<GeneralModel>, String?>((ref, stateCode) {
  return ref.read(generalLookupRepositoryProvider).getPostcodes(stateCode: stateCode);
});

final premiseAreasProvider = FutureProvider.family<List<GeneralModel>, GeneralAreaFilter>((ref, filter) {
  return ref.read(generalLookupRepositoryProvider).getAreas(
        stateCode: filter.stateCode,
        postcode: filter.postcode,
      );
});

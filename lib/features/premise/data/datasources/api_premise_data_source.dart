import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';

import 'premise_data_source.dart';

/// API-backed premise data source — wired in a later phase.
class ApiPremiseDataSource implements PremiseDataSource {
  const ApiPremiseDataSource();

  @override
  Future<PremiseSubmitResult> create(PremiseForm form) {
    throw UnimplementedError('Premise API create is not wired yet.');
  }

  @override
  Future<PremiseSubmitResult> update(PremiseForm form) {
    throw UnimplementedError('Premise API update is not wired yet.');
  }

  @override
  Future<void> uploadImage({required String visitNo, required String localPath, String? typeCode, int? seq}) {
    throw UnimplementedError('Premise photo upload API is not wired yet.');
  }
}

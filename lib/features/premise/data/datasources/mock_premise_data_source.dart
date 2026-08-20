import 'package:ilms/features/premise/data/models/premise_submit_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';

import 'premise_data_source.dart';

class MockPremiseDataSource implements PremiseDataSource {
  const MockPremiseDataSource();

  @override
  Future<PremiseSubmitResult> create(PremiseForm form) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    PremiseSubmitPayloadModel.fromDomain(form); // validates mapping
    return PremiseSubmitResult(
      visitNo: 'MOCK-${DateTime.now().millisecondsSinceEpoch}',
      updatedAt: DateTime.now().toIso8601String(),
      pendingImageUploads: form.censusImages.where((image) => image.isLocalOnly).length,
    );
  }

  @override
  Future<PremiseSubmitResult> update(PremiseForm form) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return PremiseSubmitResult(
      visitNo: form.visitNo ?? 'MOCK-UPDATE',
      updatedAt: DateTime.now().toIso8601String(),
      pendingImageUploads: form.censusImages.where((image) => image.isLocalOnly).length,
    );
  }

  @override
  Future<void> uploadImage({required String visitNo, required String localPath, String? typeCode, int? seq}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}

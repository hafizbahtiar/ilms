import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';

abstract class PremiseDataSource {
  Future<PremiseSubmitResult> create(PremiseForm form);

  Future<PremiseSubmitResult> update(PremiseForm form);

  Future<void> uploadImage({
    required String visitNo,
    required String localPath,
    String? typeCode,
    int? seq,
    String process = 'create',
    void Function(double progress)? onProgress,
  });

  /// Deletes an already-uploaded census photo by its server-side image ID.
  Future<void> deletePhoto({required String imageId});
}

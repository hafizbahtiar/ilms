import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';

abstract class PremiseRepository {
  Future<PremiseSubmitResult> submitCreate(PremiseForm form);

  Future<PremiseSubmitResult> submitUpdate(PremiseForm form);

  /// Uploads locally captured images after the main form submit succeeds.
  Future<int> uploadPendingImages({
    required String visitNo,
    required PremiseForm form,
    String process = 'create',
  });
}

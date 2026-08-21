import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';

abstract class PremiseRepository {
  Future<PremiseSubmitResult> submitCreate(PremiseForm form);

  Future<PremiseSubmitResult> submitUpdate(PremiseForm form);

  /// Uploads locally captured images after the main form submit succeeds.
  Future<int> uploadPendingImages({required String visitNo, required PremiseForm form, String process = 'create'});

  /// Uploads a single locally captured image, reporting fractional progress
  /// — used by the post-submit upload sheet so each photo has its own bar.
  Future<void> uploadImage({
    required String visitNo,
    required PremiseCensusImage image,
    String process = 'create',
    void Function(double progress)? onProgress,
  });

  /// Deletes an already-uploaded census photo by its server-side image ID.
  Future<void> deletePhoto({required String imageId});
}

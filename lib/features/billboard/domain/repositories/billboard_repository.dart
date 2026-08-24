import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_submit_result.dart';

abstract class BillboardRepository {
  Future<BillboardSubmitResult> submitCreate(BillboardForm form);

  Future<BillboardSubmitResult> submitUpdate(BillboardForm form);

  /// Uploads locally captured photos after the main form submit succeeds.
  Future<int> uploadPendingPhotos({
    required String billboardNo,
    required BillboardForm form,
    String process = 'create',
  });

  /// Uploads a single locally captured photo, reporting fractional progress.
  Future<void> uploadPhoto({
    required String billboardNo,
    required BillboardPhoto photo,
    String process = 'create',
    void Function(double progress)? onProgress,
  });

  /// Deletes an already-uploaded billboard photo by its server-side image ID.
  Future<void> deletePhoto({required String photoId});
}

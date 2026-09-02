import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_submit_result.dart';
import 'package:ilms/shared/models/general_model.dart';

abstract class BillboardDataSource {
  Future<BillboardSubmitResult> create(BillboardForm form);

  Future<BillboardSubmitResult> update(BillboardForm form);

  Future<void> uploadPhoto({
    required String billboardNo,
    required String localPath,
    String process = 'create',
    int seq = 1,
    void Function(double progress)? onProgress,
  });

  /// Deletes an already-uploaded billboard photo by its server-side image ID.
  Future<void> deletePhoto({required String photoId});

  /// Billboard-specific remark options — not the shared `/api/listRemark` lookup.
  Future<List<GeneralModel>> fetchRemarkOptions();
}

import 'package:ilms/features/billboard/data/models/billboard_submit_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_submit_result.dart';
import 'package:ilms/shared/models/general_model.dart';

import 'billboard_data_source.dart';

/// Test-only in-memory stand-in — not wired to production DI.
class MockBillboardDataSource implements BillboardDataSource {
  const MockBillboardDataSource();

  @override
  Future<BillboardSubmitResult> create(BillboardForm form) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    BillboardSubmitPayloadModel.fromDomain(form); // validates mapping
    return BillboardSubmitResult(
      billboardNo: 'MOCK-${DateTime.now().millisecondsSinceEpoch}',
      updatedAt: DateTime.now().toIso8601String(),
      pendingImageUploads: form.photos.where((photo) => photo.isLocalOnly).length,
    );
  }

  @override
  Future<BillboardSubmitResult> update(BillboardForm form) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return BillboardSubmitResult(
      billboardNo: form.billboardNo ?? 'MOCK-UPDATE',
      updatedAt: DateTime.now().toIso8601String(),
      pendingImageUploads: form.photos.where((photo) => photo.isLocalOnly).length,
    );
  }

  @override
  Future<void> uploadPhoto({
    required String billboardNo,
    required String localPath,
    String process = 'create',
    int seq = 1,
    void Function(double progress)? onProgress,
  }) async {
    for (var i = 1; i <= 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 24));
      onProgress?.call(i / 5);
    }
  }

  @override
  Future<void> deletePhoto({required String photoId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<List<GeneralModel>> fetchRemarkOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const [
      GeneralModel(code: 'PROJEK_TERBENGKALAI', desc: 'PROJEK TERBENGKALAI'),
      GeneralModel(code: 'TIADA_PAPAN_CADANGAN', desc: 'TIADA PAPAN CADANGAN'),
      GeneralModel(code: 'OTHERS', desc: 'Others'),
    ];
  }
}

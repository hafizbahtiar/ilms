import 'package:ilms/features/billboard/data/datasources/billboard_data_source.dart';
import 'package:ilms/features/billboard/data/models/billboard_submit_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_submit_result.dart';
import 'package:ilms/features/billboard/domain/exceptions/billboard_exception.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_repository.dart';

class BillboardRepositoryImpl implements BillboardRepository {
  BillboardRepositoryImpl(this._dataSource);

  final BillboardDataSource _dataSource;

  @override
  Future<BillboardSubmitResult> submitCreate(BillboardForm form) async {
    try {
      BillboardSubmitPayloadModel.fromDomain(form).toCreateJson();
      return await _dataSource.create(form);
    } catch (e) {
      throw BillboardSubmitException('Failed to submit billboard census: $e');
    }
  }

  @override
  Future<BillboardSubmitResult> submitUpdate(BillboardForm form) async {
    try {
      BillboardSubmitPayloadModel.fromDomain(form).toUpdateJson();
      return await _dataSource.update(form);
    } catch (e) {
      throw BillboardSubmitException('Failed to update billboard census: $e');
    }
  }

  @override
  Future<int> uploadPendingPhotos({
    required String billboardNo,
    required BillboardForm form,
    String process = 'create',
  }) async {
    final pending = form.photos.where((photo) => photo.isLocalOnly && photo.localPath != null).toList();
    if (pending.isEmpty) return 0;

    var uploaded = 0;
    for (var i = 0; i < pending.length; i++) {
      final photo = pending[i];
      try {
        await _dataSource.uploadPhoto(
          billboardNo: billboardNo,
          localPath: photo.localPath!,
          process: process,
          seq: i + 1,
        );
        uploaded++;
      } catch (e) {
        throw BillboardImageUploadException('Failed to upload photo ${i + 1}: $e');
      }
    }
    return uploaded;
  }

  @override
  Future<void> uploadPhoto({
    required String billboardNo,
    required BillboardPhoto photo,
    String process = 'create',
    void Function(double progress)? onProgress,
  }) async {
    final localPath = photo.localPath;
    if (localPath == null) return;

    try {
      await _dataSource.uploadPhoto(
        billboardNo: billboardNo,
        localPath: localPath,
        process: process,
        onProgress: onProgress,
      );
    } catch (e) {
      throw BillboardImageUploadException('Failed to upload photo: $e');
    }
  }

  @override
  Future<void> deletePhoto({required String photoId}) async {
    try {
      await _dataSource.deletePhoto(photoId: photoId);
    } catch (e) {
      throw BillboardImageDeleteException('Failed to delete photo: $e');
    }
  }
}

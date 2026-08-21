import 'package:ilms/features/premise/data/datasources/premise_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_submit_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_submit_result.dart';
import 'package:ilms/features/premise/domain/exceptions/premise_exception.dart';
import 'package:ilms/features/premise/domain/repositories/premise_repository.dart';

class PremiseRepositoryImpl implements PremiseRepository {
  PremiseRepositoryImpl(this._dataSource);

  final PremiseDataSource _dataSource;

  static String _resolveTypeCode(PremiseCensusImage image) {
    final code = image.typeCode?.trim();
    if (code != null && code.isNotEmpty) return code;
    return PremiseCensusImageDefaults.typeCode;
  }

  @override
  Future<PremiseSubmitResult> submitCreate(PremiseForm form) async {
    try {
      PremiseSubmitPayloadModel.fromDomain(form).toCreateJson();
      return await _dataSource.create(form);
    } catch (e) {
      throw PremiseSubmitException('Failed to submit premise census: $e');
    }
  }

  @override
  Future<PremiseSubmitResult> submitUpdate(PremiseForm form) async {
    try {
      PremiseSubmitPayloadModel.fromDomain(form).toUpdateJson();
      return await _dataSource.update(form);
    } catch (e) {
      throw PremiseSubmitException('Failed to update premise census: $e');
    }
  }

  @override
  Future<int> uploadPendingImages({
    required String visitNo,
    required PremiseForm form,
    String process = 'create',
  }) async {
    final pending = form.censusImages.where((image) => image.isLocalOnly && image.localPath != null).toList();
    if (pending.isEmpty) return 0;

    var uploaded = 0;
    for (var i = 0; i < pending.length; i++) {
      final image = pending[i];
      try {
        await _dataSource.uploadImage(
          visitNo: visitNo,
          localPath: image.localPath!,
          typeCode: _resolveTypeCode(image),
          seq: image.uploadSeq ?? i + 1,
          process: process,
        );
        uploaded++;
      } catch (e) {
        throw PremiseImageUploadException('Failed to upload image ${i + 1}: $e');
      }
    }
    return uploaded;
  }

  @override
  Future<void> uploadImage({
    required String visitNo,
    required PremiseCensusImage image,
    String process = 'create',
    void Function(double progress)? onProgress,
  }) async {
    final localPath = image.localPath;
    if (localPath == null) return;

    try {
      await _dataSource.uploadImage(
        visitNo: visitNo,
        localPath: localPath,
        typeCode: _resolveTypeCode(image),
        seq: image.uploadSeq ?? 1,
        process: process,
        onProgress: onProgress,
      );
    } catch (e) {
      throw PremiseImageUploadException('Failed to upload image: $e');
    }
  }

  @override
  Future<void> deletePhoto({required String imageId}) async {
    try {
      await _dataSource.deletePhoto(imageId: imageId);
    } catch (e) {
      throw PremiseImageDeleteException('Failed to delete image: $e');
    }
  }
}

import 'dart:typed_data';

import 'package:ilms/features/investigation/data/datasources/investigation_data_source.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_submit_result.dart';
import 'package:ilms/features/investigation/domain/exceptions/investigation_exception.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_repository.dart';

class InvestigationRepositoryImpl implements InvestigationRepository {
  InvestigationRepositoryImpl(this._dataSource);

  final InvestigationDataSource _dataSource;

  @override
  Future<InvestigationSubmitResult> update(InvestigationDetails details) async {
    try {
      return await _dataSource.update(details);
    } on InvestigationException {
      rethrow;
    } catch (e) {
      throw InvestigationSubmitException('Failed to update investigation: $e');
    }
  }

  @override
  Future<void> uploadPhoto({required String investigationNo, required int sequence, required Uint8List bytes}) async {
    try {
      await _dataSource.uploadPhoto(investigationNo: investigationNo, sequence: sequence, bytes: bytes);
    } on InvestigationException {
      rethrow;
    } catch (e) {
      throw InvestigationPhotoUploadException('Failed to upload photo: $e');
    }
  }
}

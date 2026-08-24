import 'dart:typed_data';

import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_submit_result.dart';

abstract class InvestigationRepository {
  Future<InvestigationSubmitResult> update(InvestigationDetails details);

  /// Uploads one photo, sequentially — legacy uploads photos one call per
  /// image via `/api/investigation/create-photo` after the main update
  /// succeeds.
  Future<void> uploadPhoto({required String investigationNo, required int sequence, required Uint8List bytes});
}

import 'dart:typed_data';

import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_submit_result.dart';

abstract class InvestigationDataSource {
  Future<InvestigationSubmitResult> update(InvestigationDetails details);

  Future<void> uploadPhoto({required String investigationNo, required int sequence, required Uint8List bytes});
}

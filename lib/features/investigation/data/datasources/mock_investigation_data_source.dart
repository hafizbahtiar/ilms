import 'dart:typed_data';

import 'package:ilms/features/investigation/data/datasources/investigation_data_source.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_submit_result.dart';

/// Test-only, not wired to production DI.
class MockInvestigationDataSource implements InvestigationDataSource {
  const MockInvestigationDataSource();

  @override
  Future<InvestigationSubmitResult> update(InvestigationDetails details) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return InvestigationSubmitResult(investigationNo: details.investigationNo);
  }

  @override
  Future<void> uploadPhoto({required String investigationNo, required int sequence, required Uint8List bytes}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

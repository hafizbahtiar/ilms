import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';

/// Low-level detail API access. Maps 1:1 to the network endpoint — not used by UI directly.
abstract class InvestigationDetailRemoteDataSource {
  Future<InvestigationDetails> getDetail(String investigationNo);
}

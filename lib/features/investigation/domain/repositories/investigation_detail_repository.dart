import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';

abstract class InvestigationDetailRepository {
  Future<InvestigationDetails> getDetail(String investigationNo);
}

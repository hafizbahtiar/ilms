import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_detail_record.dart';

/// Low-level detail API access. Maps 1:1 to the network endpoint — not used by UI directly.
abstract class PremiseDetailRemoteDataSource {
  /// Form-shaped snapshot (view/edit flows) — see [PremiseDetailMapper.fromApiDetail].
  Future<PremiseDraftPayloadModel> getDetail(String visitNo);

  /// Read-only document snapshot (History detail page) — see [PremiseDetailMapper.toDetailRecord].
  Future<PremiseDetailRecord> getDetailRecord(String visitNo);
}

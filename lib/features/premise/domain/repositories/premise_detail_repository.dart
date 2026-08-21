import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_detail_record.dart';

/// Full-record read access to `/api/premiseCensus/detail` — unlike the
/// duplicate-flow variant, this includes census images and the visit's own
/// findings (remarks, licenses, business activities), for viewing/editing an
/// existing premise record rather than seeding a fresh draft.
abstract class PremiseDetailRepository {
  /// Form-shaped snapshot, for the view/edit form flow.
  Future<PremiseDraftPayloadModel> getDetail(String visitNo);

  /// Read-only document snapshot, for the History detail page.
  Future<PremiseDetailRecord> getDetailRecord(String visitNo);
}

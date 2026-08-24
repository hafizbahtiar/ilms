import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';

/// Full-record read access for viewing/editing an existing billboard.
abstract class BillboardDetailRepository {
  Future<BillboardForm> getDetail(String billboardNo);
}

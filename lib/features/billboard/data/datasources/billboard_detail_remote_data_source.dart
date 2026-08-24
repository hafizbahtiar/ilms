import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';

/// Low-level detail API access. Maps 1:1 to the network endpoint — not used by UI directly.
abstract class BillboardDetailRemoteDataSource {
  Future<BillboardForm> getDetail(String billboardNo);
}

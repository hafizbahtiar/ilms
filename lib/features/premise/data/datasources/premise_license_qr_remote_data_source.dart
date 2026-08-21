import 'package:ilms/features/premise/data/models/premise_license_qr_model.dart';

abstract class PremiseLicenseQrRemoteDataSource {
  Future<PremiseLicenseQrModel> getByLink(String link);
}

import 'package:ilms/features/premise/domain/entities/premise_license_qr_data.dart';

abstract class PremiseLicenseQrRepository {
  /// Resolves the license data behind a scanned QR/barcode [link].
  Future<PremiseLicenseQrData> fetchByLink(String link);
}

import 'package:ilms/features/premise/data/models/premise_license_qr_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_qr_data.dart';

class PremiseLicenseQrMapper {
  PremiseLicenseQrMapper._();

  static PremiseLicenseQrData toDomain(PremiseLicenseQrModel model) {
    return PremiseLicenseQrData(
      licenseCategory: model.licenseCategory,
      licenseHolderName: model.licenseHolderName,
      licenseFileNo: model.licenseFileNo,
      licenseStatus: model.licenseStatus,
      premiseAddress: model.premiseAddress,
      companyRegistrationNo: model.companyRegistrationNo,
      licenseGrade: model.licenseGrade,
      licenseDateFrom: model.licenseDateFrom,
      licenseDateTo: model.licenseDateTo,
    );
  }
}

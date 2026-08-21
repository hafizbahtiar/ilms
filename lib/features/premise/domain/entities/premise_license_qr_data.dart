import 'package:equatable/equatable.dart';

/// License data resolved from a scanned QR/barcode via
/// `/api/premiseCensus/licenseQrLink` — used to prefill the license form
/// instead of the surveyor typing it in by hand.
class PremiseLicenseQrData extends Equatable {
  const PremiseLicenseQrData({
    this.licenseCategory,
    this.licenseHolderName,
    this.licenseFileNo,
    this.licenseStatus,
    this.premiseAddress,
    this.companyRegistrationNo,
    this.licenseGrade,
    this.licenseDateFrom,
    this.licenseDateTo,
  });

  final String? licenseCategory;
  final String? licenseHolderName;
  final String? licenseFileNo;
  final String? licenseStatus;
  final String? premiseAddress;
  final String? companyRegistrationNo;
  final String? licenseGrade;

  /// `dd/MM/yyyy`, matching the rest of the app's date-field convention.
  final String? licenseDateFrom;
  final String? licenseDateTo;

  @override
  List<Object?> get props => [
    licenseCategory,
    licenseHolderName,
    licenseFileNo,
    licenseStatus,
    premiseAddress,
    companyRegistrationNo,
    licenseGrade,
    licenseDateFrom,
    licenseDateTo,
  ];
}

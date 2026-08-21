/// Wire shape of `/api/premiseCensus/licenseQrLink`'s `data` object.
class PremiseLicenseQrModel {
  const PremiseLicenseQrModel({
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

  factory PremiseLicenseQrModel.fromJson(Map<String, dynamic> json) {
    return PremiseLicenseQrModel(
      licenseCategory: json['license_category'] as String?,
      licenseHolderName: json['license_holder_name'] as String?,
      licenseFileNo: json['license_file_no'] as String?,
      licenseStatus: json['license_status'] as String?,
      premiseAddress: json['premise_address'] as String?,
      companyRegistrationNo: json['company_registration_no'] as String?,
      licenseGrade: json['license_grade'] as String?,
      licenseDateFrom: json['license_date_from'] as String?,
      licenseDateTo: json['license_date_to'] as String?,
    );
  }

  final String? licenseCategory;
  final String? licenseHolderName;
  final String? licenseFileNo;
  final String? licenseStatus;
  final String? premiseAddress;
  final String? companyRegistrationNo;
  final String? licenseGrade;
  final String? licenseDateFrom;
  final String? licenseDateTo;
}

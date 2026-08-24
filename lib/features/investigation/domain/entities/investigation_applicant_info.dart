import 'package:equatable/equatable.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_code_description.dart';

/// Read-only — sourced from the case record, not editable from the app.
class InvestigationApplicantInfo extends Equatable {
  const InvestigationApplicantInfo({
    this.licenseFileNo,
    this.applicantName,
    this.identificationNo,
    this.companyName,
    this.registrationNo,
    this.businessTypes = const [],
    this.advertisementTypes = const [],
  });

  final String? licenseFileNo;
  final String? applicantName;
  final String? identificationNo;
  final String? companyName;
  final String? registrationNo;
  final List<InvestigationCodeDescription> businessTypes;
  final List<InvestigationCodeDescription> advertisementTypes;

  @override
  List<Object?> get props => [
    licenseFileNo,
    applicantName,
    identificationNo,
    companyName,
    registrationNo,
    businessTypes,
    advertisementTypes,
  ];
}

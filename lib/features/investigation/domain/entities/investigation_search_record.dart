import 'package:equatable/equatable.dart';

/// A flat summary row from `/api/investigation/search`, shared by the
/// search and history list pages.
class InvestigationSearchRecord extends Equatable {
  const InvestigationSearchRecord({
    required this.investigationNo,
    this.investigationId,
    this.licenseFileNo,
    this.dateReceived,
    this.applicantName,
    this.companyName,
    this.typeCode,
    this.priorityCode,
    this.statusCode,
    this.areaCode,
    this.investigationOfficer,
    this.investigationStartDate,
    this.businessType,
    this.createdDate,
  });

  final String investigationNo;
  final String? investigationId;
  final String? licenseFileNo;
  final String? dateReceived;
  final String? applicantName;
  final String? companyName;
  final String? typeCode;
  final String? priorityCode;
  final String? statusCode;
  final String? areaCode;
  final String? investigationOfficer;
  final String? investigationStartDate;
  final String? businessType;
  final String? createdDate;

  @override
  List<Object?> get props => [
    investigationNo,
    investigationId,
    licenseFileNo,
    dateReceived,
    applicantName,
    companyName,
    typeCode,
    priorityCode,
    statusCode,
    areaCode,
    investigationOfficer,
    investigationStartDate,
    businessType,
    createdDate,
  ];
}

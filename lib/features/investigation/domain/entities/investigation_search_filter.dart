import 'package:equatable/equatable.dart';

/// 11 filters exposed by the search UI — reused, minus the filter sheet, by
/// the history list (legacy has no separate history endpoint).
class InvestigationSearchFilter extends Equatable {
  const InvestigationSearchFilter({
    this.investigationNo,
    this.licenseNo,
    this.identificationNo,
    this.companyName,
    this.registrationNo,
    this.parliamentCode,
    this.areaCode,
    this.statusCode,
    this.officerName,
    this.dateReceived,
    this.investigationStartDateFrom,
    this.investigationStartDateTo,
    this.businessTypeCode,
  });

  final String? investigationNo;
  final String? licenseNo;
  final String? identificationNo;
  final String? companyName;
  final String? registrationNo;
  final String? parliamentCode;
  final String? areaCode;
  final String? statusCode;
  final String? officerName;
  final String? dateReceived;
  final String? investigationStartDateFrom;
  final String? investigationStartDateTo;
  final String? businessTypeCode;

  bool get isEmpty => [
    investigationNo,
    licenseNo,
    identificationNo,
    companyName,
    registrationNo,
    parliamentCode,
    areaCode,
    statusCode,
    officerName,
    dateReceived,
    investigationStartDateFrom,
    investigationStartDateTo,
    businessTypeCode,
  ].every((value) => value == null || value.trim().isEmpty);

  InvestigationSearchFilter copyWith({
    String? investigationNo,
    String? licenseNo,
    String? identificationNo,
    String? companyName,
    String? registrationNo,
    String? parliamentCode,
    String? areaCode,
    String? statusCode,
    String? officerName,
    String? dateReceived,
    String? investigationStartDateFrom,
    String? investigationStartDateTo,
    String? businessTypeCode,
  }) {
    return InvestigationSearchFilter(
      investigationNo: investigationNo ?? this.investigationNo,
      licenseNo: licenseNo ?? this.licenseNo,
      identificationNo: identificationNo ?? this.identificationNo,
      companyName: companyName ?? this.companyName,
      registrationNo: registrationNo ?? this.registrationNo,
      parliamentCode: parliamentCode ?? this.parliamentCode,
      areaCode: areaCode ?? this.areaCode,
      statusCode: statusCode ?? this.statusCode,
      officerName: officerName ?? this.officerName,
      dateReceived: dateReceived ?? this.dateReceived,
      investigationStartDateFrom: investigationStartDateFrom ?? this.investigationStartDateFrom,
      investigationStartDateTo: investigationStartDateTo ?? this.investigationStartDateTo,
      businessTypeCode: businessTypeCode ?? this.businessTypeCode,
    );
  }

  @override
  List<Object?> get props => [
    investigationNo,
    licenseNo,
    identificationNo,
    companyName,
    registrationNo,
    parliamentCode,
    areaCode,
    statusCode,
    officerName,
    dateReceived,
    investigationStartDateFrom,
    investigationStartDateTo,
    businessTypeCode,
  ];
}

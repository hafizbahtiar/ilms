import 'package:ilms/features/investigation/domain/entities/investigation_search_filter.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_record.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_result.dart';

/// Request body for `/api/investigation/search`, mirroring legacy
/// `SearchSiasatanFilterModel`'s field names.
class InvestigationSearchFilterDto {
  const InvestigationSearchFilterDto({
    this.investigationNo = '',
    this.licenseNo = '',
    this.identificationNo = '',
    this.companyName = '',
    this.registrationNo = '',
    this.parliamentCode = '',
    this.areaCode = '',
    this.statusCode = '',
    this.officerName = '',
    this.dateReceived = '',
    this.investigationStartDateFrom = '',
    this.investigationStartDateTo = '',
    this.businessTypeCode = '',
  });

  final String investigationNo;
  final String licenseNo;
  final String identificationNo;
  final String companyName;
  final String registrationNo;
  final String parliamentCode;
  final String areaCode;
  final String statusCode;
  final String officerName;
  final String dateReceived;
  final String investigationStartDateFrom;
  final String investigationStartDateTo;
  final String businessTypeCode;

  factory InvestigationSearchFilterDto.fromDomain(InvestigationSearchFilter filter) {
    return InvestigationSearchFilterDto(
      investigationNo: filter.investigationNo ?? '',
      licenseNo: filter.licenseNo ?? '',
      identificationNo: filter.identificationNo ?? '',
      companyName: filter.companyName ?? '',
      registrationNo: filter.registrationNo ?? '',
      parliamentCode: filter.parliamentCode ?? '',
      areaCode: filter.areaCode ?? '',
      statusCode: filter.statusCode ?? '',
      officerName: filter.officerName ?? '',
      dateReceived: filter.dateReceived ?? '',
      investigationStartDateFrom: filter.investigationStartDateFrom ?? '',
      investigationStartDateTo: filter.investigationStartDateTo ?? '',
      businessTypeCode: filter.businessTypeCode ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'investigation_no': investigationNo,
    'license_no': licenseNo,
    'identification_no': identificationNo,
    'company_name': companyName,
    'registration_no': registrationNo,
    'parliament_code': parliamentCode,
    'area_code': areaCode,
    'status_code': statusCode,
    'officer_name': officerName,
    'date_received': dateReceived,
    'investigation_start_date_from': investigationStartDateFrom,
    'investigation_start_date_to': investigationStartDateTo,
    'business_type_code': businessTypeCode,
  };
}

class InvestigationSearchRecordDto {
  const InvestigationSearchRecordDto({
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

  InvestigationSearchRecord toDomain() {
    return InvestigationSearchRecord(
      investigationNo: investigationNo,
      investigationId: investigationId,
      licenseFileNo: licenseFileNo,
      dateReceived: dateReceived,
      applicantName: applicantName,
      companyName: companyName,
      typeCode: typeCode,
      priorityCode: priorityCode,
      statusCode: statusCode,
      areaCode: areaCode,
      investigationOfficer: investigationOfficer,
      investigationStartDate: investigationStartDate,
      businessType: businessType,
      createdDate: createdDate,
    );
  }

  factory InvestigationSearchRecordDto.fromJson(Map<String, dynamic> json) {
    return InvestigationSearchRecordDto(
      investigationNo: json['investigation_no']?.toString() ?? '',
      investigationId: json['investigation_id']?.toString(),
      licenseFileNo: json['license_file_no']?.toString(),
      dateReceived: json['date_received']?.toString(),
      applicantName: json['applicant_name']?.toString(),
      companyName: json['company_name']?.toString(),
      typeCode: json['type_code']?.toString(),
      priorityCode: json['priority_code']?.toString(),
      statusCode: json['status_code']?.toString(),
      areaCode: json['area_code']?.toString(),
      investigationOfficer: json['investigation_officer']?.toString(),
      investigationStartDate: json['investigation_start_date']?.toString(),
      businessType: json['business_type']?.toString(),
      createdDate: json['created_date']?.toString(),
    );
  }
}

class InvestigationSearchResultDto {
  const InvestigationSearchResultDto({required this.items, required this.nextPage, required this.hasNextPage});

  final List<InvestigationSearchRecordDto> items;
  final int nextPage;
  final bool hasNextPage;

  InvestigationSearchResult toDomain() {
    return InvestigationSearchResult(
      items: items.map((item) => item.toDomain()).toList(),
      nextPage: nextPage,
      hasNextPage: hasNextPage,
    );
  }
}

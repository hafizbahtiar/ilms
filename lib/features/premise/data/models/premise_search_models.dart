import 'package:ilms/features/premise/domain/entities/premise_search_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_record.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_result.dart';

class PremiseSearchFilterDto {
  const PremiseSearchFilterDto({
    this.keyword = '',
    this.licenseFileNo = '',
    this.licenseNo = '',
    this.unit = '',
    this.building = '',
    this.street = '',
    this.area = '',
    this.parliament = '',
    this.companyName = '',
    this.traderName = '',
    this.phase = '',
  });

  final String keyword;
  final String licenseFileNo;
  final String licenseNo;
  final String unit;
  final String building;
  final String street;
  final String area;
  final String parliament;
  final String companyName;
  final String traderName;
  final String phase;

  factory PremiseSearchFilterDto.fromDomain(PremiseSearchFilter filter) {
    return PremiseSearchFilterDto(
      keyword: filter.keyword,
      licenseFileNo: filter.licenseFileNo,
      licenseNo: filter.licenseNo,
      unit: filter.unit,
      building: filter.building,
      street: filter.street,
      area: filter.area,
      parliament: filter.parliament,
      companyName: filter.companyName,
      traderName: filter.traderName,
      phase: filter.phase,
    );
  }

  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'license_file_no': licenseFileNo,
    'license_no': licenseNo,
    'unit': unit,
    'building': building,
    'street': street,
    'area': area,
    'parliament': parliament,
    'company_name': companyName,
    'trader_name': traderName,
    'phase': phase,
  };
}

class PremiseSearchRecordDto {
  const PremiseSearchRecordDto({
    required this.visitNo,
    this.companyName,
    this.traderName,
    this.address,
    this.visitStatus,
    this.phase,
    this.visitDate,
    this.createdBy,
  });

  final String visitNo;
  final String? companyName;
  final String? traderName;
  final String? address;
  final String? visitStatus;
  final String? phase;
  final String? visitDate;
  final String? createdBy;

  PremiseSearchRecord toDomain() {
    return PremiseSearchRecord(
      visitNo: visitNo,
      companyName: companyName,
      traderName: traderName,
      address: address,
      visitStatus: visitStatus,
      phase: phase,
      visitDate: visitDate,
      createdBy: createdBy,
    );
  }

  factory PremiseSearchRecordDto.fromJson(Map<String, dynamic> json) {
    return PremiseSearchRecordDto(
      visitNo: json['visit_no']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      traderName: json['trader_name']?.toString(),
      address: json['address']?.toString(),
      visitStatus: json['visit_status']?.toString(),
      phase: json['phase']?.toString(),
      visitDate: json['visit_date']?.toString(),
      createdBy: json['created_by']?.toString(),
    );
  }
}

class PremiseSearchResultDto {
  const PremiseSearchResultDto({
    required this.items,
    required this.nextPage,
    required this.hasNextPage,
  });

  final List<PremiseSearchRecordDto> items;
  final int nextPage;
  final bool hasNextPage;

  PremiseSearchResult toDomain() {
    return PremiseSearchResult(
      items: items.map((item) => item.toDomain()).toList(),
      nextPage: nextPage,
      hasNextPage: hasNextPage,
    );
  }
}

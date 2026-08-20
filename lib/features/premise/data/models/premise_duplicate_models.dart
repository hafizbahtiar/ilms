import 'package:ilms/features/premise/domain/entities/premise_duplicate_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_record.dart';

class PremiseDuplicateFilterDto {
  const PremiseDuplicateFilterDto({
    this.parliament = '',
    this.area = '',
    this.street = '',
    this.building = '',
    this.unit = '',
    this.companyName = '',
    this.traderName = '',
    this.licenseNo = '',
    this.licenseFileNo = '',
  });

  final String parliament;
  final String area;
  final String street;
  final String building;
  final String unit;
  final String companyName;
  final String traderName;
  final String licenseNo;
  final String licenseFileNo;

  factory PremiseDuplicateFilterDto.fromDomain(PremiseDuplicateFilter filter) {
    return PremiseDuplicateFilterDto(
      parliament: filter.parliament,
      area: filter.area,
      street: filter.street,
      building: filter.building,
      unit: filter.unit,
      companyName: filter.companyName,
      traderName: filter.traderName,
      licenseNo: filter.licenseNo,
      licenseFileNo: filter.licenseFileNo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parliament': parliament,
      'area': area,
      'street': street,
      'building': building,
      'unit': unit,
      'company_name': companyName,
      'trader_name': traderName,
      'license_no': licenseNo,
      'license_file_no': licenseFileNo,
    };
  }
}

class PremiseDuplicateRecordDto {
  const PremiseDuplicateRecordDto({
    required this.visitNo,
    this.companyName,
    this.traderName,
    this.address,
    this.visitStatus,
    this.phase,
    this.visitDate,
    this.createdBy,
    this.parliament,
    this.area,
    this.street,
    this.building,
    this.unit,
    this.canDuplicate = true,
    this.blockMessage,
  });

  final String visitNo;
  final String? companyName;
  final String? traderName;
  final String? address;
  final String? visitStatus;
  final String? phase;
  final String? visitDate;
  final String? createdBy;
  final String? parliament;
  final String? area;
  final String? street;
  final String? building;
  final String? unit;
  final bool canDuplicate;
  final String? blockMessage;

  PremiseDuplicateRecord toDomain() {
    return PremiseDuplicateRecord(
      visitNo: visitNo,
      companyName: companyName,
      traderName: traderName,
      address: address,
      visitStatus: visitStatus,
      phase: phase,
      visitDate: visitDate,
      createdBy: createdBy,
      parliament: parliament,
      area: area,
      street: street,
      building: building,
      unit: unit,
    );
  }

  factory PremiseDuplicateRecordDto.fromJson(Map<String, dynamic> json) {
    return PremiseDuplicateRecordDto(
      visitNo: json['visit_no'] as String? ?? '',
      companyName: json['company_name'] as String?,
      traderName: json['trader_name'] as String?,
      address: json['address'] as String?,
      visitStatus: json['visit_status'] as String?,
      phase: json['phase'] as String?,
      visitDate: json['visit_date'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  bool matches(PremiseDuplicateFilterDto filter) {
    bool matchField(String recordValue, String filterValue) {
      if (filterValue.isEmpty) return true;
      return recordValue.trim().toLowerCase() == filterValue.trim().toLowerCase();
    }

    return matchField(parliament ?? '', filter.parliament) &&
        matchField(area ?? '', filter.area) &&
        matchField(street ?? '', filter.street) &&
        matchField(building ?? '', filter.building) &&
        matchField(unit ?? '', filter.unit) &&
        matchField(companyName ?? '', filter.companyName) &&
        matchField(traderName ?? '', filter.traderName);
  }
}

class PremiseDuplicateResultDto {
  const PremiseDuplicateResultDto({
    required this.items,
    required this.nextPage,
    required this.hasNextPage,
  });

  final List<PremiseDuplicateRecordDto> items;
  final int nextPage;
  final bool hasNextPage;
}

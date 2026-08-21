import 'package:equatable/equatable.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';

/// Read-only aggregate for a full premise record — backs the History
/// document detail page. Distinct from [PremiseForm]: this is never
/// submitted, so it also carries audit metadata the form has no use for.
class PremiseDetailRecord extends Equatable {
  const PremiseDetailRecord({
    required this.visitNo,
    required this.companyContact,
    required this.details,
    this.addresses = const [],
    this.licenses = const [],
    this.businessActivities = const [],
    this.remarks = const [],
    this.censusImages = const [],
    this.visitStatus,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  final String visitNo;
  final PremiseCompanyContact companyContact;
  final PremiseDetails details;
  final List<PremiseAddress> addresses;
  final List<PremiseLicense> licenses;
  final List<PremiseBusinessActivity> businessActivities;
  final List<PremiseRemark> remarks;
  final List<PremiseCensusImage> censusImages;
  final String? visitStatus;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  String get displayTitle {
    final company = companyContact.companyName?.trim() ?? '';
    if (company.isNotEmpty) return company;
    final trader = details.traderName?.trim() ?? '';
    if (trader.isNotEmpty) return trader;
    return visitNo;
  }

  String get displaySubtitle {
    final trader = details.traderName?.trim() ?? '';
    if (trader.isNotEmpty && trader != displayTitle) return trader;
    return visitNo;
  }

  @override
  List<Object?> get props => [
    visitNo,
    companyContact,
    details,
    addresses,
    licenses,
    businessActivities,
    remarks,
    censusImages,
    visitStatus,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];
}

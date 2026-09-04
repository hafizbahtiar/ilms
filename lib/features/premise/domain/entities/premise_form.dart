import 'package:equatable/equatable.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_gps.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';

/// Aggregate root for the premise census form.
class PremiseForm extends Equatable {
  const PremiseForm({
    this.visitNo,
    this.updatedAt,
    this.localDraftId,
    required this.companyContact,
    required this.details,
    this.gps = const PremiseGps(),
    this.addresses = const [],
    this.licenses = const [],
    this.businessActivities = const [],
    this.remarks = const [],
    this.censusImages = const [],
    this.visitStatus,
    this.visitStatusDesc,
  });

  final String? visitNo;
  final String? updatedAt;
  final int? localDraftId;
  final PremiseCompanyContact companyContact;
  final PremiseDetails details;
  final PremiseGps gps;
  final List<PremiseAddress> addresses;
  final List<PremiseLicense> licenses;
  final List<PremiseBusinessActivity> businessActivities;
  final List<PremiseRemark> remarks;
  final List<PremiseCensusImage> censusImages;

  /// Picked via the "Choose Visit Status" step right before submit
  /// (legacy `PremisSubmitView`) — required by the server on create/update.
  final String? visitStatus;
  final String? visitStatusDesc;

  bool get isUpdate => visitNo != null && visitNo!.isNotEmpty;

  PremiseForm copyWith({
    String? visitNo,
    String? updatedAt,
    int? localDraftId,
    PremiseCompanyContact? companyContact,
    PremiseDetails? details,
    PremiseGps? gps,
    List<PremiseAddress>? addresses,
    List<PremiseLicense>? licenses,
    List<PremiseBusinessActivity>? businessActivities,
    List<PremiseRemark>? remarks,
    List<PremiseCensusImage>? censusImages,
    String? visitStatus,
    String? visitStatusDesc,
  }) {
    return PremiseForm(
      visitNo: visitNo ?? this.visitNo,
      updatedAt: updatedAt ?? this.updatedAt,
      localDraftId: localDraftId ?? this.localDraftId,
      companyContact: companyContact ?? this.companyContact,
      details: details ?? this.details,
      gps: gps ?? this.gps,
      addresses: addresses ?? this.addresses,
      licenses: licenses ?? this.licenses,
      businessActivities: businessActivities ?? this.businessActivities,
      remarks: remarks ?? this.remarks,
      censusImages: censusImages ?? this.censusImages,
      visitStatus: visitStatus ?? this.visitStatus,
      visitStatusDesc: visitStatusDesc ?? this.visitStatusDesc,
    );
  }

  @override
  List<Object?> get props => [
    visitNo,
    updatedAt,
    localDraftId,
    companyContact,
    details,
    gps,
    addresses,
    licenses,
    businessActivities,
    remarks,
    censusImages,
    visitStatus,
    visitStatusDesc,
  ];
}

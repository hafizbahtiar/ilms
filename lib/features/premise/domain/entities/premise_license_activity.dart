import 'package:equatable/equatable.dart';

/// One business activity attached to a [PremiseLicense] (legacy
/// `AdditionalLicenseInfo`) — a license can carry several of these.
class PremiseLicenseActivity extends Equatable {
  const PremiseLicenseActivity({
    this.businessType,
    this.businessTypeDesc,
    this.status,
    this.statusDesc,
    this.description,
    this.amount,
    this.saveToBusiness = false,
    this.businessActivityLocalId,
  });

  final String? businessType;
  final String? businessTypeDesc;
  final String? status;
  final String? statusDesc;
  final String? description;
  final String? amount;

  /// UI-only: when true, this item is also mirrored into the standalone
  /// Business Activity section on save.
  final bool saveToBusiness;

  /// UI-only bookkeeping: [PremiseBusinessActivity.localId] this item was
  /// already mirrored to. Lets re-saving the license update that row instead
  /// of inserting a duplicate every time.
  final int? businessActivityLocalId;

  PremiseLicenseActivity copyWith({
    String? businessType,
    String? businessTypeDesc,
    String? status,
    String? statusDesc,
    String? description,
    String? amount,
    bool? saveToBusiness,
    int? businessActivityLocalId,
  }) {
    return PremiseLicenseActivity(
      businessType: businessType ?? this.businessType,
      businessTypeDesc: businessTypeDesc ?? this.businessTypeDesc,
      status: status ?? this.status,
      statusDesc: statusDesc ?? this.statusDesc,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      saveToBusiness: saveToBusiness ?? this.saveToBusiness,
      businessActivityLocalId: businessActivityLocalId ?? this.businessActivityLocalId,
    );
  }

  @override
  List<Object?> get props => [
    businessType,
    businessTypeDesc,
    status,
    statusDesc,
    description,
    amount,
    saveToBusiness,
    businessActivityLocalId,
  ];
}

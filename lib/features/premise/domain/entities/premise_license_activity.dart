import 'package:equatable/equatable.dart';

/// One business activity attached to a [PremiseLicense] (legacy
/// `AdditionalLicenseInfo`) — a license can carry several of these.
class PremiseLicenseActivity extends Equatable {
  const PremiseLicenseActivity({
    this.id,
    this.businessType,
    this.businessTypeDesc,
    this.status,
    this.statusDesc,
    this.description,
    this.amount,
  });

  /// Server row id — resubmitted so the backend updates this row instead of
  /// inserting a duplicate.
  final int? id;
  final String? businessType;
  final String? businessTypeDesc;
  final String? status;
  final String? statusDesc;
  final String? description;
  final String? amount;

  PremiseLicenseActivity copyWith({
    int? id,
    String? businessType,
    String? businessTypeDesc,
    String? status,
    String? statusDesc,
    String? description,
    String? amount,
  }) {
    return PremiseLicenseActivity(
      id: id ?? this.id,
      businessType: businessType ?? this.businessType,
      businessTypeDesc: businessTypeDesc ?? this.businessTypeDesc,
      status: status ?? this.status,
      statusDesc: statusDesc ?? this.statusDesc,
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [id, businessType, businessTypeDesc, status, statusDesc, description, amount];
}

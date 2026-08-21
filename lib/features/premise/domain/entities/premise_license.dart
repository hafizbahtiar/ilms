import 'package:equatable/equatable.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';

class PremiseLicense extends Equatable {
  const PremiseLicense({
    this.id,
    this.localId,
    this.licenseNo,
    this.licenseFileNo,
    this.validFrom,
    this.validTo,
    this.status,
    this.statusDesc,
    this.businessActivities = const [],
  });

  final int? id;
  final int? localId;
  final String? licenseNo;
  final String? licenseFileNo;
  final String? validFrom;
  final String? validTo;
  final String? status;

  /// Human-readable label for [status] (e.g. `"V : Valid"`), carried
  /// alongside the code so the list/sheet don't need a lookup round-trip.
  final String? statusDesc;

  /// Repeatable business activities under this single license (legacy
  /// "Multiple Business Activities").
  final List<PremiseLicenseActivity> businessActivities;

  /// Convenience: total of every item's amount, used for list summaries.
  double get totalAmount => businessActivities.fold<double>(
    0,
    (sum, item) => sum + (double.tryParse((item.amount ?? '').replaceAll(',', '')) ?? 0),
  );

  PremiseLicense copyWith({
    int? id,
    int? localId,
    String? licenseNo,
    String? licenseFileNo,
    String? validFrom,
    String? validTo,
    String? status,
    String? statusDesc,
    List<PremiseLicenseActivity>? businessActivities,
  }) {
    return PremiseLicense(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      licenseNo: licenseNo ?? this.licenseNo,
      licenseFileNo: licenseFileNo ?? this.licenseFileNo,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      status: status ?? this.status,
      statusDesc: statusDesc ?? this.statusDesc,
      businessActivities: businessActivities ?? this.businessActivities,
    );
  }

  @override
  List<Object?> get props => [
    id,
    localId,
    licenseNo,
    licenseFileNo,
    validFrom,
    validTo,
    status,
    statusDesc,
    businessActivities,
  ];
}

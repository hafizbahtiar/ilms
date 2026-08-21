import 'package:equatable/equatable.dart';

class PremiseBusinessActivity extends Equatable {
  const PremiseBusinessActivity({
    this.id,
    this.localId,
    this.businessType,
    this.businessTypeDesc,
    this.status,
    this.statusDesc,
    this.description,
  });

  final int? id;

  /// Local-only identity assigned when this activity is created (whether
  /// added directly or mirrored from a license's "Save to Business Activity"
  /// item) — lets a license re-mirror into the same row on a later edit
  /// instead of inserting a duplicate.
  final int? localId;
  final String? businessType;
  final String? businessTypeDesc;
  final String? status;
  final String? statusDesc;
  final String? description;

  PremiseBusinessActivity copyWith({
    int? id,
    int? localId,
    String? businessType,
    String? businessTypeDesc,
    String? status,
    String? statusDesc,
    String? description,
  }) {
    return PremiseBusinessActivity(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      businessType: businessType ?? this.businessType,
      businessTypeDesc: businessTypeDesc ?? this.businessTypeDesc,
      status: status ?? this.status,
      statusDesc: statusDesc ?? this.statusDesc,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, localId, businessType, businessTypeDesc, status, statusDesc, description];
}

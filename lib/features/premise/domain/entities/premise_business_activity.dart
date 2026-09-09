import 'package:equatable/equatable.dart';

class PremiseBusinessActivity extends Equatable {
  const PremiseBusinessActivity({
    this.id,
    this.businessType,
    this.businessTypeDesc,
    this.status,
    this.statusDesc,
    this.description,
    this.floors = const [],
  });

  final int? id;
  final String? businessType;
  final String? businessTypeDesc;
  final String? status;
  final String? statusDesc;
  final String? description;
  final List<String> floors;

  PremiseBusinessActivity copyWith({
    int? id,
    String? businessType,
    String? businessTypeDesc,
    String? status,
    String? statusDesc,
    String? description,
    List<String>? floors,
  }) {
    return PremiseBusinessActivity(
      id: id ?? this.id,
      businessType: businessType ?? this.businessType,
      businessTypeDesc: businessTypeDesc ?? this.businessTypeDesc,
      status: status ?? this.status,
      statusDesc: statusDesc ?? this.statusDesc,
      description: description ?? this.description,
      floors: floors ?? this.floors,
    );
  }

  @override
  List<Object?> get props => [id, businessType, businessTypeDesc, status, statusDesc, description, floors];
}

import 'package:equatable/equatable.dart';

class PremiseBusinessActivity extends Equatable {
  const PremiseBusinessActivity({
    this.id,
    this.localId,
    this.activityCode,
    this.activityDescription,
    this.remarks,
  });

  final int? id;
  final int? localId;
  final String? activityCode;
  final String? activityDescription;
  final String? remarks;

  @override
  List<Object?> get props => [id, localId, activityCode, activityDescription, remarks];
}

import 'package:equatable/equatable.dart';

class PremiseDetails extends Equatable {
  const PremiseDetails({
    this.traderName,
    this.businessTypeCode,
    this.businessTypeDescription,
    this.premiseTypeCode,
    this.premiseTypeDescription,
    this.width,
    this.length,
  });

  final String? traderName;
  final String? businessTypeCode;
  final String? businessTypeDescription;
  final String? premiseTypeCode;
  final String? premiseTypeDescription;
  final String? width;
  final String? length;

  @override
  List<Object?> get props => [
    traderName,
    businessTypeCode,
    businessTypeDescription,
    premiseTypeCode,
    premiseTypeDescription,
    width,
    length,
  ];
}

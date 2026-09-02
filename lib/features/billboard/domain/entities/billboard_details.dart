import 'package:equatable/equatable.dart';

class BillboardDetails extends Equatable {
  const BillboardDetails({
    this.phaseCode,
    this.phaseDesc,
    this.description,
    this.billboardTypeCode,
    this.billboardTypeDesc,
    this.isLedBoard = false,
    this.isLight = false,
    this.isPotential = false,
    this.hoardingStartDate,
    this.hoardingCompleteDate,
  });

  final String? phaseCode;
  final String? phaseDesc;
  final String? description;
  final String? billboardTypeCode;
  final String? billboardTypeDesc;
  final bool isLedBoard;
  final bool isLight;
  final bool isPotential;
  final String? hoardingStartDate;
  final String? hoardingCompleteDate;

  BillboardDetails copyWith({
    String? phaseCode,
    String? phaseDesc,
    String? description,
    String? billboardTypeCode,
    String? billboardTypeDesc,
    bool? isLedBoard,
    bool? isLight,
    bool? isPotential,
    String? hoardingStartDate,
    String? hoardingCompleteDate,
  }) {
    return BillboardDetails(
      phaseCode: phaseCode ?? this.phaseCode,
      phaseDesc: phaseDesc ?? this.phaseDesc,
      description: description ?? this.description,
      billboardTypeCode: billboardTypeCode ?? this.billboardTypeCode,
      billboardTypeDesc: billboardTypeDesc ?? this.billboardTypeDesc,
      isLedBoard: isLedBoard ?? this.isLedBoard,
      isLight: isLight ?? this.isLight,
      isPotential: isPotential ?? this.isPotential,
      hoardingStartDate: hoardingStartDate ?? this.hoardingStartDate,
      hoardingCompleteDate: hoardingCompleteDate ?? this.hoardingCompleteDate,
    );
  }

  @override
  List<Object?> get props => [
    phaseCode,
    phaseDesc,
    description,
    billboardTypeCode,
    billboardTypeDesc,
    isLedBoard,
    isLight,
    isPotential,
    hoardingStartDate,
    hoardingCompleteDate,
  ];
}

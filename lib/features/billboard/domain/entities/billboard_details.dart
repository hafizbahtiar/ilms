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
    this.hordingStartDate,
    this.hordingCompleteDate,
  });

  final String? phaseCode;
  final String? phaseDesc;
  final String? description;
  final String? billboardTypeCode;
  final String? billboardTypeDesc;
  final bool isLedBoard;
  final bool isLight;
  final bool isPotential;
  final String? hordingStartDate;
  final String? hordingCompleteDate;

  BillboardDetails copyWith({
    String? phaseCode,
    String? phaseDesc,
    String? description,
    String? billboardTypeCode,
    String? billboardTypeDesc,
    bool? isLedBoard,
    bool? isLight,
    bool? isPotential,
    String? hordingStartDate,
    String? hordingCompleteDate,
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
      hordingStartDate: hordingStartDate ?? this.hordingStartDate,
      hordingCompleteDate: hordingCompleteDate ?? this.hordingCompleteDate,
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
    hordingStartDate,
    hordingCompleteDate,
  ];
}

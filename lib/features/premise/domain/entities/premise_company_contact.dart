import 'package:equatable/equatable.dart';

/// Section 1 — company census details + registered address + contact person.
class PremiseCompanyContact extends Equatable {
  const PremiseCompanyContact({
    this.localId,
    this.companyName,
    this.registerNumber,
    this.companyTelNo,
    this.companyFaxNo,
    this.stickerNo,
    this.censusDate,
    this.unit,
    this.building,
    this.street1,
    this.street2,
    this.stateCode,
    this.stateDescription,
    this.postcode,
    this.areaCode,
    this.areaDescription,
    this.contactPersonName,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.contactPersonPosition,
  });

  final int? localId;
  final String? companyName;
  final String? registerNumber;
  final String? companyTelNo;
  final String? companyFaxNo;
  final String? stickerNo;
  final String? censusDate;
  final String? unit;
  final String? building;
  final String? street1;
  final String? street2;
  final String? stateCode;
  final String? stateDescription;
  final String? postcode;
  final String? areaCode;
  final String? areaDescription;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final String? contactPersonEmail;
  final String? contactPersonPosition;

  @override
  List<Object?> get props => [
    localId,
    companyName,
    registerNumber,
    companyTelNo,
    companyFaxNo,
    stickerNo,
    censusDate,
    unit,
    building,
    street1,
    street2,
    stateCode,
    stateDescription,
    postcode,
    areaCode,
    areaDescription,
    contactPersonName,
    contactPersonPhone,
    contactPersonEmail,
    contactPersonPosition,
  ];
}

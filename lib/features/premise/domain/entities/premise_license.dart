import 'package:equatable/equatable.dart';

class PremiseLicense extends Equatable {
  const PremiseLicense({
    this.id,
    this.localId,
    this.licenseNo,
    this.licenseFileNo,
    this.validFrom,
    this.validTo,
    this.status,
  });

  final int? id;
  final int? localId;
  final String? licenseNo;
  final String? licenseFileNo;
  final String? validFrom;
  final String? validTo;
  final String? status;

  @override
  List<Object?> get props => [id, localId, licenseNo, licenseFileNo, validFrom, validTo, status];
}

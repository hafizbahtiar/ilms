import 'package:equatable/equatable.dart';

/// Legacy `LicenseDetails` — single text field, no auto-prefix (unlike
/// premise's license file no).
class BillboardLicense extends Equatable {
  const BillboardLicense({this.fileNo});

  final String? fileNo;

  BillboardLicense copyWith({String? fileNo}) {
    return BillboardLicense(fileNo: fileNo ?? this.fileNo);
  }

  @override
  List<Object?> get props => [fileNo];
}

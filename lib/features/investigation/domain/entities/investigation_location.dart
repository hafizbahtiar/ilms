import 'package:equatable/equatable.dart';

/// Parlimen & Kawasan — read-only, fixed by the case record (officers cannot
/// edit political/geographic classification from the app).
class InvestigationLocation extends Equatable {
  const InvestigationLocation({this.parliamentCode, this.parliamentDesc, this.areaCode, this.areaDesc});

  final String? parliamentCode;
  final String? parliamentDesc;
  final String? areaCode;
  final String? areaDesc;

  @override
  List<Object?> get props => [parliamentCode, parliamentDesc, areaCode, areaDesc];
}

import 'package:equatable/equatable.dart';

/// Single coordinate for the whole premise record, captured via `AppMapField`
/// — mirrors [BillboardGps]. Replaces the old per-address `latitude`/
/// `longitude` on [PremiseAddress]: a premise census can carry multiple
/// addresses, but has exactly one physical location.
class PremiseGps extends Equatable {
  const PremiseGps({this.latitude, this.longitude});

  final String? latitude;
  final String? longitude;

  bool get hasCoordinate => latitude != null && longitude != null;

  PremiseGps copyWith({String? latitude, String? longitude}) {
    return PremiseGps(latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude);
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

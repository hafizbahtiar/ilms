import 'package:equatable/equatable.dart';

/// Single coordinate captured via `AppMapField` (legacy `GpsDetails`).
class BillboardGps extends Equatable {
  const BillboardGps({this.latitude, this.longitude});

  final String? latitude;
  final String? longitude;

  bool get hasCoordinate => latitude != null && longitude != null;

  BillboardGps copyWith({String? latitude, String? longitude}) {
    return BillboardGps(latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude);
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

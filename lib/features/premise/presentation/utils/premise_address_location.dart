import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:latlong2/latlong.dart';

LatLng? latLngFromPremiseAddress(PremiseAddress address) {
  final lat = double.tryParse(address.latitude ?? '');
  final lng = double.tryParse(address.longitude ?? '');
  if (lat == null || lng == null) return null;
  return LatLng(lat, lng);
}

bool premiseAddressHasLocation(PremiseAddress address) => latLngFromPremiseAddress(address) != null;

PremiseAddress premiseAddressWithCoordinates(PremiseAddress address, LatLng coordinates) {
  return address.copyWith(latitude: coordinates.latitude.toString(), longitude: coordinates.longitude.toString());
}

String formatPremiseCoordinates(PremiseAddress address) {
  final latLng = latLngFromPremiseAddress(address);
  if (latLng == null) return '-';
  return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
}

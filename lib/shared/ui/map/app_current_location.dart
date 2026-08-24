import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AppLocationFailure implements Exception {
  const AppLocationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Resolves the device's current GPS position after checking services and
/// permission. Throws [AppLocationFailure] with a user-facing message.
Future<LatLng> resolveAppCurrentLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw const AppLocationFailure('Location services are turned off.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw const AppLocationFailure('Location permission was denied.');
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );

  return LatLng(position.latitude, position.longitude);
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilms/shared/ui/map/app_map_limits.dart';
import 'package:latlong2/latlong.dart' as geo;

/// Responsive [GoogleMap] wrapper shared by previews and the location picker.
class AppMapView extends StatelessWidget {
  const AppMapView({
    super.key,
    required this.center,
    this.zoom = AppMapLimits.defaultZoom,
    this.minZoom = AppMapLimits.minZoom,
    this.maxZoom = AppMapLimits.maxZoom,
    this.interactionFlags = 0,
    this.markers = const <Marker>{},
    this.onMapCreated,
    this.onCameraMove,
  });

  final geo.LatLng center;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final int interactionFlags;
  final Set<Marker> markers;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<CameraPosition>? onCameraMove;

  static const pickerFlags = 1 | 2 | 4 | 8;
  static const previewFlags = 0;

  bool _hasFlag(int flag) => interactionFlags & flag != 0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GoogleMap(
        key: ValueKey('${center.latitude},${center.longitude}'),
        initialCameraPosition: CameraPosition(
          target: LatLng(center.latitude, center.longitude),
          zoom: AppMapLimits.clampZoom(zoom),
        ),
        minMaxZoomPreference: MinMaxZoomPreference(minZoom, maxZoom),
        markers: markers,
        zoomGesturesEnabled: _hasFlag(1),
        scrollGesturesEnabled: _hasFlag(2),
        rotateGesturesEnabled: _hasFlag(4),
        tiltGesturesEnabled: _hasFlag(8),
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        myLocationButtonEnabled: false,
        onMapCreated: onMapCreated,
        onCameraMove: onCameraMove,
      ),
    );
  }
}

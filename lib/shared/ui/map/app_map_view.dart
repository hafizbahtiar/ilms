import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ilms/shared/ui/map/app_map_limits.dart';
import 'package:ilms/shared/ui/map/app_map_tile_layer.dart';
import 'package:latlong2/latlong.dart';

/// Responsive [FlutterMap] wrapper shared by previews and the location picker.
class AppMapView extends StatelessWidget {
  const AppMapView({
    super.key,
    this.mapController,
    required this.center,
    this.zoom = AppMapLimits.defaultZoom,
    this.minZoom = AppMapLimits.minZoom,
    this.maxZoom = AppMapLimits.maxZoom,
    this.interactionFlags = InteractiveFlag.none,
    this.instantTiles = false,
    this.highDensityTiles,
    this.interactiveTiles = false,
    this.layers = const [],
    this.onMapReady,
  });

  final MapController? mapController;
  final LatLng center;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final int interactionFlags;
  final bool instantTiles;
  final bool? highDensityTiles;
  final bool interactiveTiles;
  final List<Widget> layers;
  final VoidCallback? onMapReady;

  /// Full-screen picker — pan, zoom, and two-finger rotate enabled.
  static const pickerFlags = InteractiveFlag.all;

  /// Static coordinate preview inside a form.
  static const previewFlags = InteractiveFlag.none;

  /// Static previews have no [mapController]; [FlutterMap] only reads
  /// [MapOptions.initialCenter] on first mount, so tie the element key to the
  /// coordinate when nothing else will drive camera moves.
  Key? get _previewCenterKey => mapController == null ? ValueKey('${center.latitude},${center.longitude}') : null;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FlutterMap(
        key: _previewCenterKey,
        mapController: mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: AppMapLimits.clampZoom(zoom),
          minZoom: minZoom,
          maxZoom: maxZoom,
          interactionOptions: InteractionOptions(flags: interactionFlags),
          onMapReady: onMapReady,
        ),
        children: [
          AppMapTileLayer(instant: instantTiles, highDensity: highDensityTiles, interactive: interactiveTiles),
          ...layers,
        ],
      ),
    );
  }
}

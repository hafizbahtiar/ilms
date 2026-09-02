import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ilms/shared/ui/map/app_map_limits.dart';

/// Shared raster tiles for in-app map previews and the location picker.
///
/// NOTE: Google's undocumented raster endpoint — fine for dev/demo; swap to
/// an official provider before production.
class AppMapTileLayer extends StatelessWidget {
  const AppMapTileLayer({
    super.key,
    this.instant = false,
    this.highDensity,
    this.interactive = false,
  });

  static const userAgentPackageName = 'com.example.ilms';

  /// Skip fade-in when tiles load — better for small static previews.
  final bool instant;

  /// When `false`, skips retina tile requests (cheaper for thumbnails).
  /// Defaults to [RetinaMode.isHighDensity] when unset.
  final bool? highDensity;

  /// Wider tile buffer for pannable/rotatable maps.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    // Retina simulation requests 4x tiles and lowers effective max zoom — keep
    // it off for interactive maps to avoid blank tiles while pinching.
    final useRetina = highDensity ?? (!interactive && RetinaMode.isHighDensity(context));

    return TileLayer(
      urlTemplate: 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
      userAgentPackageName: userAgentPackageName,
      maxNativeZoom: AppMapLimits.maxNativeZoom,
      minNativeZoom: AppMapLimits.minNativeZoom,
      keepBuffer: interactive ? 3 : 2,
      panBuffer: interactive ? 2 : 1,
      retinaMode: useRetina,
      tileDisplay: instant ? const TileDisplay.instantaneous() : const TileDisplay.fadeIn(),
    );
  }
}

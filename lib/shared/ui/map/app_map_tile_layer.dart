import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Shared raster tiles for in-app map previews and the location picker.
///
/// NOTE: Google's undocumented raster endpoint — fine for dev/demo; swap to
/// an official provider before production.
class AppMapTileLayer extends StatelessWidget {
  const AppMapTileLayer({super.key});

  static const userAgentPackageName = 'com.example.ilms';

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
      userAgentPackageName: userAgentPackageName,
    );
  }
}

/// Shared zoom bounds for every in-app map instance.
///
/// Google raster tiles only exist between z1–z19; clamping here prevents invalid
/// tile requests that can crash or blank the map.
abstract final class AppMapLimits {
  static const minZoom = 3.0;
  static const minNativeZoom = 1;

  /// Native tile ceiling for Google raster endpoints.
  static const maxNativeZoom = 19;
  static const maxZoom = 19.0;

  static const defaultZoom = 15.0;
  static const locateZoom = 16.0;
  static const previewZoom = 16.0;

  static double clampZoom(double zoom) => zoom.clamp(minZoom, maxZoom);
}

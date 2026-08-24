import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ilms/shared/ui/map/app_map_tile_layer.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen "pick a location" map, reusable across any form that needs a
/// coordinate (premise/billboard/investigation address, etc).
///
/// UX: a fixed reticle sits at the center of the screen as the user pans;
/// "Current Location" jumps the map to the device's GPS position; "Mark
/// Location" freezes the reticle's current point as the actual pick (shown
/// as a distinct marker + in the coordinate readout); "Proceed" confirms
/// and returns it — disabled until something's been marked, so a user can't
/// accidentally submit wherever they happened to leave the map panned.
///
/// Returns the picked [LatLng], or `null` if cancelled.
class AppLocationPickerPage extends StatefulWidget {
  const AppLocationPickerPage({super.key, this.initialCenter, this.title = 'Pick Location', this.viewOnly = false});

  final LatLng? initialCenter;
  final String title;
  final bool viewOnly;

  /// Kuala Lumpur — used only when no [initialCenter] is given and the
  /// device's current location can't be resolved either.
  static const fallbackCenter = LatLng(3.1390, 101.6869);

  static Future<LatLng?> open(
    BuildContext context, {
    LatLng? initialCenter,
    String title = 'Pick Location',
    bool viewOnly = false,
  }) {
    return Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AppLocationPickerPage(initialCenter: initialCenter, title: title, viewOnly: viewOnly),
      ),
    );
  }

  @override
  State<AppLocationPickerPage> createState() => _AppLocationPickerPageState();
}

class _AppLocationPickerPageState extends State<AppLocationPickerPage> {
  final _mapController = MapController();
  LatLng? _markedLocation;
  var _isLocating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    if (widget.viewOnly && widget.initialCenter != null) {
      _markedLocation = widget.initialCenter;
    } else if (!widget.viewOnly && widget.initialCenter == null) {
      // Best-effort: if the caller didn't pass a starting point, try to open
      // centered on the device's own location instead of Kuala Lumpur.
      _locateMe(silent: true);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _locateMe({bool silent = false}) async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const _LocationUnavailable('Location services are turned off.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw const _LocationUnavailable('Location permission was denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;

      final here = LatLng(position.latitude, position.longitude);
      _mapController.move(here, 16);
    } on _LocationUnavailable catch (e) {
      // Silent on the automatic open-time attempt — the map still opens
      // fine centered on the fallback, no need to alarm the user for
      // something they didn't explicitly ask for yet.
      if (!silent && mounted) setState(() => _locationError = e.message);
    } catch (_) {
      if (!silent && mounted) setState(() => _locationError = 'Unable to get your current location.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _markLocation() => setState(() => _markedLocation = _mapController.camera.center);

  void _proceed() {
    final marked = _markedLocation;
    if (marked == null) return;
    Navigator.of(context).pop(marked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter ?? _markedLocation ?? AppLocationPickerPage.fallbackCenter,
                initialZoom: 15,
                interactionOptions: InteractionOptions(
                  flags: widget.viewOnly ? InteractiveFlag.none : InteractiveFlag.all,
                ),
              ),
              children: [
                const AppMapTileLayer(),
                // MarkerLayer/Marker call MapCamera.of(context) internally to
                // position themselves against the map's viewport — it MUST
                // live inside FlutterMap's own children, not as a sibling in
                // the outer Stack, or that lookup fails.
                if (_markedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _markedLocation!,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: Icon(Icons.location_on_rounded, size: 40, color: cs.primary),
                      ),
                    ],
                  ),
              ],
            ),
            // Reticle — always centered on screen, guides where "Mark
            // Location" will drop its pin as the user pans underneath it.
            IgnorePointer(
              child: Center(child: Icon(Icons.add_rounded, size: 28, color: cs.error.withValues(alpha: 0.85))),
            ),
            if (_locationError != null)
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: Material(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 18, color: cs.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_locationError!, style: TextStyle(color: cs.onErrorContainer)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (!widget.viewOnly)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _BottomPanel(
                  markedLocation: _markedLocation,
                  isLocating: _isLocating,
                  onCurrentLocation: () => _locateMe(),
                  onMarkLocation: _markLocation,
                  onProceed: _markedLocation == null ? null : _proceed,
                ),
              )
            else if (_markedLocation != null)
              Positioned(left: 16, right: 16, bottom: 16, child: _ViewOnlyPanel(markedLocation: _markedLocation!)),
          ],
        ),
      ),
    );
  }
}

class _ViewOnlyPanel extends StatelessWidget {
  const _ViewOnlyPanel({required this.markedLocation});

  final LatLng markedLocation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${markedLocation.latitude.toStringAsFixed(6)}, ${markedLocation.longitude.toStringAsFixed(6)}',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.markedLocation,
    required this.isLocating,
    required this.onCurrentLocation,
    required this.onMarkLocation,
    required this.onProceed,
  });

  final LatLng? markedLocation;
  final bool isLocating;
  final VoidCallback onCurrentLocation;
  final VoidCallback onMarkLocation;
  final VoidCallback? onProceed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final marked = markedLocation;

    return Material(
      color: cs.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  marked != null ? Icons.location_on_rounded : Icons.location_searching_rounded,
                  size: 18,
                  color: marked != null ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    marked != null
                        ? '${marked.latitude.toStringAsFixed(6)}, ${marked.longitude.toStringAsFixed(6)}'
                        : 'Pan the map, then tap Mark Location',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: marked != null ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLocating ? null : onCurrentLocation,
                    icon: isLocating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text('Current Location'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMarkLocation,
                    icon: const Icon(Icons.push_pin_outlined, size: 18),
                    label: const Text('Mark Location'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(onPressed: onProceed, child: const Text('Proceed')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationUnavailable implements Exception {
  const _LocationUnavailable(this.message);
  final String message;
}

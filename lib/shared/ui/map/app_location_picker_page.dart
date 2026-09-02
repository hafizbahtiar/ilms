import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ilms/shared/ui/map/app_current_location.dart';
import 'package:ilms/shared/ui/map/app_map_limits.dart';
import 'package:ilms/shared/ui/map/app_map_rotation_reset_button.dart';
import 'package:ilms/shared/ui/map/app_map_view.dart';
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
  var _mapReady = false;
  var _needsSilentLocate = false;
  LatLng? _pendingMoveCenter;
  double? _pendingMoveZoom;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    if (widget.viewOnly && widget.initialCenter != null) {
      _markedLocation = widget.initialCenter;
    } else if (!widget.viewOnly && widget.initialCenter == null) {
      _needsSilentLocate = true;
    }
  }

  void _onMapReady() {
    _mapReady = true;
    _flushPendingMove();
    if (_needsSilentLocate) {
      _needsSilentLocate = false;
      _locateMe(silent: true);
    }
  }

  void _flushPendingMove() {
    final center = _pendingMoveCenter;
    final zoom = _pendingMoveZoom;
    if (center == null || zoom == null) return;

    _pendingMoveCenter = null;
    _pendingMoveZoom = null;
    _moveMap(center, zoom);
  }

  bool _moveMap(LatLng center, double zoom) {
    try {
      return _mapController.move(center, AppMapLimits.clampZoom(zoom));
    } on Exception {
      _pendingMoveCenter = center;
      _pendingMoveZoom = zoom;
      return false;
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
      final here = await resolveAppCurrentLocation();
      if (!mounted) return;
      _moveMap(here, AppMapLimits.locateZoom);
    } on AppLocationFailure catch (error) {
      if (!silent && mounted) setState(() => _locationError = error.message);
    } catch (_) {
      if (!silent && mounted) setState(() => _locationError = 'Unable to get your current location.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _markLocation() {
    try {
      setState(() => _markedLocation = _mapController.camera.center);
    } on Exception {
      // Map not ready — ignore.
    }
  }

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
            AppMapView(
              mapController: _mapController,
              center: widget.initialCenter ?? _markedLocation ?? AppLocationPickerPage.fallbackCenter,
              zoom: AppMapLimits.defaultZoom,
              interactionFlags: widget.viewOnly ? AppMapView.previewFlags : AppMapView.pickerFlags,
              interactiveTiles: !widget.viewOnly,
              onMapReady: _onMapReady,
              layers: [
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
            if (!widget.viewOnly && _mapReady)
              Positioned(
                top: 12,
                right: 12,
                child: AppMapRotationResetButton(mapController: _mapController),
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
                  compact: MediaQuery.orientationOf(context) == Orientation.landscape,
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
    required this.compact,
    required this.onCurrentLocation,
    required this.onMarkLocation,
    required this.onProceed,
  });

  final LatLng? markedLocation;
  final bool isLocating;
  final bool compact;
  final VoidCallback onCurrentLocation;
  final VoidCallback onMarkLocation;
  final VoidCallback? onProceed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final marked = markedLocation;

    final coordinateRow = Row(
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
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: marked != null ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );

    final actionButtons = Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLocating ? null : onCurrentLocation,
            icon: isLocating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location_rounded, size: 18),
            label: Text(compact ? 'Current' : 'Current Location'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onMarkLocation,
            icon: const Icon(Icons.push_pin_outlined, size: 18),
            label: Text(compact ? 'Mark' : 'Mark Location'),
          ),
        ),
      ],
    );

    final proceedButton = SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(onPressed: onProceed, child: const Text('Proceed')),
    );

    return Material(
      color: cs.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, compact ? 12 : 14, 16, compact ? 12 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            coordinateRow,
            SizedBox(height: compact ? 8 : 12),
            actionButtons,
            SizedBox(height: compact ? 8 : 10),
            proceedButton,
          ],
        ),
      ),
    );
  }
}

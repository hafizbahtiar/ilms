import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ilms/shared/ui/map/app_current_location.dart';
import 'package:ilms/shared/ui/map/app_location_picker_page.dart';
import 'package:ilms/shared/ui/map/app_map_tile_layer.dart';
import 'package:latlong2/latlong.dart';

/// Reusable map coordinate field for forms — empty tap-to-pick state and a
/// static map preview once a location is set (same role as [AppImageField]).
class AppMapField extends StatefulWidget {
  const AppMapField({
    super.key,
    this.location,
    this.readOnly = false,
    this.label,
    this.required = false,
    this.previewHeight = 168,
    this.pickerTitle = 'Pick Location',
    this.showPickOnMapAction = true,
    this.showCurrentLocationAction = true,
    this.onChanged,
    this.currentLocationResolver,
  });

  final LatLng? location;
  final bool readOnly;
  final String? label;
  final bool required;
  final double previewHeight;
  final String pickerTitle;
  final bool showPickOnMapAction;
  final bool showCurrentLocationAction;
  final ValueChanged<LatLng?>? onChanged;

  /// Injectable for tests — defaults to [resolveAppCurrentLocation].
  final Future<LatLng> Function()? currentLocationResolver;

  @override
  State<AppMapField> createState() => _AppMapFieldState();
}

class _AppMapFieldState extends State<AppMapField> {
  var _isLocating = false;
  String? _locationError;

  bool get _hasLocation => widget.location != null;

  bool get _showEmptyActions =>
      !widget.readOnly && widget.onChanged != null && (widget.showPickOnMapAction || widget.showCurrentLocationAction);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text.rich(
            TextSpan(
              text: widget.label,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              children: [
                if (widget.required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: cs.error, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (!_hasLocation)
          _EmptyMapState(
            readOnly: widget.readOnly,
            previewHeight: widget.previewHeight,
            surfaceColor: cs.surfaceContainerLow,
            primaryColor: cs.primary,
            onSurfaceColor: cs.onSurface,
            errorColor: cs.error,
            textTheme: textTheme,
            showPickOnMapAction: widget.showPickOnMapAction,
            showCurrentLocationAction: widget.showCurrentLocationAction,
            showActions: _showEmptyActions,
            isLocating: _isLocating,
            errorMessage: _locationError,
            onPickOnMap: widget.readOnly ? null : () => _openPicker(),
            onUseCurrentLocation: widget.readOnly ? null : _useCurrentLocation,
          )
        else
          _MapPreview(
            location: widget.location!,
            readOnly: widget.readOnly,
            previewHeight: widget.previewHeight,
            onTap: _openPicker,
            onClear: widget.readOnly || widget.onChanged == null ? null : () => widget.onChanged!(null),
          ),
      ],
    );
  }

  Future<void> _openPicker() async {
    if (widget.readOnly) {
      if (!_hasLocation) return;
      await AppLocationPickerPage.open(
        context,
        title: widget.pickerTitle,
        initialCenter: widget.location,
        viewOnly: true,
      );
      return;
    }

    if (widget.onChanged == null) return;

    final picked = await AppLocationPickerPage.open(context, title: widget.pickerTitle, initialCenter: widget.location);
    if (picked == null || !mounted) return;

    setState(() => _locationError = null);
    widget.onChanged!(picked);
  }

  Future<void> _useCurrentLocation() async {
    if (widget.readOnly || widget.onChanged == null) return;

    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final resolver = widget.currentLocationResolver ?? resolveAppCurrentLocation;
      final here = await resolver();
      if (!mounted) return;
      widget.onChanged!(here);
    } on AppLocationFailure catch (error) {
      if (!mounted) return;
      setState(() => _locationError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationError = 'Unable to get your current location.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }
}

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState({
    required this.readOnly,
    required this.previewHeight,
    required this.surfaceColor,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.errorColor,
    required this.textTheme,
    required this.showPickOnMapAction,
    required this.showCurrentLocationAction,
    required this.showActions,
    required this.isLocating,
    this.errorMessage,
    this.onPickOnMap,
    this.onUseCurrentLocation,
  });

  final bool readOnly;
  final double previewHeight;
  final Color surfaceColor;
  final Color primaryColor;
  final Color onSurfaceColor;
  final Color errorColor;
  final TextTheme textTheme;
  final bool showPickOnMapAction;
  final bool showCurrentLocationAction;
  final bool showActions;
  final bool isLocating;
  final String? errorMessage;
  final VoidCallback? onPickOnMap;
  final VoidCallback? onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: previewHeight - 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isLocating ? null : onPickOnMap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 40,
                          color: readOnly ? onSurfaceColor.withValues(alpha: 0.35) : primaryColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          readOnly ? 'No location marked.' : 'Tap here or use the buttons below',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(color: onSurfaceColor.withValues(alpha: 0.65)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showActions) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (showPickOnMapAction)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLocating ? null : onPickOnMap,
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Pick on Map'),
                        ),
                      ),
                    if (showPickOnMapAction && showCurrentLocationAction) const SizedBox(width: 10),
                    if (showCurrentLocationAction)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isLocating ? null : onUseCurrentLocation,
                          icon: isLocating
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded, size: 18),
                          label: const Text('Current Location'),
                        ),
                      ),
                  ],
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: errorColor, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.location,
    required this.readOnly,
    required this.previewHeight,
    required this.onTap,
    this.onClear,
  });

  final LatLng location;
  final bool readOnly;
  final double previewHeight;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final coordinateText = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: previewHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  const AppMapTileLayer(),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: Icon(Icons.location_on_rounded, size: 36, color: cs.primary),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: cs.onPrimary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            coordinateText,
                            style: textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!readOnly)
                          Text(
                            'Edit',
                            style: textTheme.labelLarge?.copyWith(color: cs.secondary, fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (onClear != null) Positioned(top: 8, right: 8, child: _ClearButton(onTap: onClear!)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
        child: const Icon(Icons.close, size: 16, color: Colors.white),
      ),
    );
  }
}

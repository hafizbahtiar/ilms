import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ilms/shared/ui/map/app_location_picker_page.dart';
import 'package:ilms/shared/ui/map/app_map_tile_layer.dart';
import 'package:latlong2/latlong.dart';

/// Reusable map coordinate field for forms — empty tap-to-pick state and a
/// static map preview once a location is set (same role as [AppImageField]).
class AppMapField extends StatelessWidget {
  const AppMapField({
    super.key,
    this.location,
    this.readOnly = false,
    this.label,
    this.required = false,
    this.previewHeight = 168,
    this.pickerTitle = 'Pick Location',
    this.onChanged,
  });

  final LatLng? location;
  final bool readOnly;
  final String? label;
  final bool required;
  final double previewHeight;
  final String pickerTitle;
  final ValueChanged<LatLng?>? onChanged;

  bool get _hasLocation => location != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              children: [
                if (required)
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
            readOnly: readOnly,
            previewHeight: previewHeight,
            surfaceColor: cs.surfaceContainerLow,
            primaryColor: cs.primary,
            onSurfaceColor: cs.onSurface,
            textTheme: textTheme,
            onTap: readOnly ? null : () => _openPicker(context),
          )
        else
          _MapPreview(
            location: location!,
            readOnly: readOnly,
            previewHeight: previewHeight,
            onTap: () => _openPicker(context),
            onClear: readOnly || onChanged == null ? null : () => onChanged!(null),
          ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    if (readOnly) {
      if (!_hasLocation) return;
      await AppLocationPickerPage.open(
        context,
        title: pickerTitle,
        initialCenter: location,
        viewOnly: true,
      );
      return;
    }

    if (onChanged == null) return;

    final picked = await AppLocationPickerPage.open(
      context,
      title: pickerTitle,
      initialCenter: location,
    );
    if (picked == null) return;
    onChanged!(picked);
  }
}

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState({
    required this.readOnly,
    required this.previewHeight,
    required this.surfaceColor,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.textTheme,
    this.onTap,
  });

  final bool readOnly;
  final double previewHeight;
  final Color surfaceColor;
  final Color primaryColor;
  final Color onSurfaceColor;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: previewHeight,
          child: Center(
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
                  readOnly ? 'No location marked.' : 'Tap to pick location on map',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: onSurfaceColor.withValues(alpha: 0.65)),
                ),
              ],
            ),
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
              if (onClear != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _ClearButton(onTap: onClear!),
                ),
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

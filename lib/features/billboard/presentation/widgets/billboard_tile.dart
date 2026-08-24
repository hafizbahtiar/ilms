import 'package:flutter/material.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_record.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_source.dart';

class BillboardTile extends StatelessWidget {
  const BillboardTile({super.key, required this.record, required this.accentColor, this.onTap});

  final BillboardSearchRecord record;
  final Color accentColor;
  final VoidCallback? onTap;

  /// Stable per-item palette pick (hashed from [billboardNo]) so a failed
  /// image load reads as "this item's color" instead of flickering a
  /// different random shade on every rebuild.
  static const _fallbackPalette = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
    Color(0xFF00838F),
    Color(0xFFAD1457),
    Color(0xFF616161),
  ];

  static Color _fallbackColorFor(String billboardNo) =>
      _fallbackPalette[billboardNo.hashCode.abs() % _fallbackPalette.length];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final previewImage = record.previewImage?.trim();
    final hasPreviewImage = previewImage != null && previewImage.isNotEmpty;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasPreviewImage)
              _ImageHeader(
                previewImage: previewImage,
                title: record.displayTitle,
                subtitle: record.billboardNo,
                fallbackColor: _fallbackColorFor(record.billboardNo),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.billboardNo,
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.35)),
            if (_clean(record.location) case final location?)
              _InfoRow(icon: Icons.location_on_outlined, label: location, color: accentColor),
            if (_clean(record.address) case final address?)
              _InfoRow(icon: Icons.signpost_outlined, label: address, color: accentColor),
            if (_clean(record.billboardDate) case final date?)
              _InfoRow(icon: Icons.calendar_month_outlined, label: date, color: accentColor),
            if (_dateRangeLabel case final range?)
              _InfoRow(icon: Icons.date_range_outlined, label: range, color: accentColor),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  String? get _dateRangeLabel {
    final start = _clean(record.startDate);
    final complete = _clean(record.completeDate);
    if (start == null && complete == null) return null;
    return '${start ?? '-'} — ${complete ?? '-'}';
  }

  String? _clean(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

/// Full-bleed image header (no padding/border) with the title/subtitle
/// overlaid at the bottom via a scrim gradient, instead of separate text
/// below the image.
class _ImageHeader extends StatelessWidget {
  const _ImageHeader({
    required this.previewImage,
    required this.title,
    required this.subtitle,
    required this.fallbackColor,
  });

  final String previewImage;
  final String title;
  final String subtitle;
  final Color fallbackColor;

  static const _height = 160.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImageSource.thumbnail(AppImageItem(networkUrl: previewImage), failedColor: fallbackColor),
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
                  stops: const [0, 1],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

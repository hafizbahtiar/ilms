import 'package:flutter/material.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_record.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_source.dart';

class BillboardTile extends StatelessWidget {
  const BillboardTile({
    super.key,
    required this.record,
    required this.accentColor,
    this.onTap,
    this.hasUnsavedEdit = false,
  });

  final BillboardSearchRecord record;
  final Color accentColor;
  final VoidCallback? onTap;

  /// True when a local edit-session draft is pending for this record — see
  /// `billboardEditSessionBillboardNosProvider`.
  final bool hasUnsavedEdit;

  static const _tileHeight = 180.0;
  static const _defaultBannerAsset = 'assets/no_banner.jpeg';

  @override
  Widget build(BuildContext context) {
    final previewImage = record.previewImage?.trim();
    final hasPreviewImage = previewImage != null && previewImage.isNotEmpty;
    final clientName = _clean(record.mediaOwnerClient) ?? record.billboardNo;
    final address = _clean(record.address);
    final censusDate = _clean(record.billboardDate);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _tileHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasPreviewImage)
                AppImageSource.thumbnail(
                  AppImageItem(networkUrl: previewImage),
                  failedAsset: _defaultBannerAsset,
                )
              else
                Image.asset(_defaultBannerAsset, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x33000000),
                      Color(0x99000000),
                      Color(0xD9000000),
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (hasUnsavedEdit) ...[
                          const SizedBox(width: 8),
                          const _UnsavedTag(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.billboardNo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    if (address != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.signpost_outlined, label: address),
                    ],
                    if (censusDate != null) ...[
                      const SizedBox(height: 4),
                      _InfoRow(icon: Icons.calendar_month_outlined, label: censusDate),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _clean(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnsavedTag extends StatelessWidget {
  const _UnsavedTag();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Text(
        'Unsaved',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(fontWeight: FontWeight.w700, color: cs.onErrorContainer),
      ),
    );
  }
}

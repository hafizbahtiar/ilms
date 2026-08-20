import 'package:flutter/material.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_grid_sheet.dart';
import 'package:ilms/shared/ui/media/app_image_source.dart';
import 'package:ilms/shared/ui/media/app_image_viewer_page.dart';

/// Reusable image grid field for forms.
///
/// In edit mode with more than 8 images, shows 7 thumbnails, an overflow cell
/// on the 8th slot (`+N` where `N = total - 8`), and keeps the 9th slot as add.
/// Tapping the overflow cell opens a grid bottom sheet of all images.
class AppImageField extends StatelessWidget {
  const AppImageField({
    super.key,
    required this.images,
    this.readOnly = false,
    this.label,
    this.required = false,
    this.maxColumns = 3,
    this.maxRows = 3,
    this.spacing = 8,
    this.onAdd,
    this.onRemove,
    this.onImageTap,
    this.onOverflowTap,
    this.emptyPlaceholder,
  });

  final List<AppImageItem> images;
  final bool readOnly;
  final String? label;
  final bool required;
  final int maxColumns;
  final int maxRows;
  final double spacing;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;
  final ValueChanged<int>? onImageTap;
  final VoidCallback? onOverflowTap;
  final Widget? emptyPlaceholder;

  static const _maxCells = 9;
  static const _editOverflowThreshold = 8;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final slots = _buildSlots();

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
        if (slots.isEmpty)
          _EmptyImageState(
            readOnly: readOnly,
            onAdd: onAdd,
            color: cs.primary,
            textTheme: textTheme,
            surfaceColor: cs.surfaceContainerLow,
            onSurfaceColor: cs.onSurface,
            placeholder: emptyPlaceholder,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - spacing * (maxColumns - 1)) / maxColumns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final slot in slots)
                    SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: _ImageCell(
                        slot: slot,
                        readOnly: readOnly,
                        onTap: () => _handleTap(context, slot),
                        onRemove: slot.imageIndex != null && onRemove != null && !readOnly
                            ? () => onRemove!(slot.imageIndex!)
                            : null,
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  void _handleTap(BuildContext context, _ImageGridSlot slot) {
    switch (slot.kind) {
      case _ImageGridSlotKind.add:
        onAdd?.call();
      case _ImageGridSlotKind.overflow:
        if (onOverflowTap != null) {
          onOverflowTap!();
        } else {
          showAppImageGridSheet(context, images: images);
        }
      case _ImageGridSlotKind.image:
        if (slot.imageIndex != null) {
          if (onImageTap != null) {
            onImageTap!(slot.imageIndex!);
          } else {
            showAppImageViewer(context, images: images, initialIndex: slot.imageIndex!);
          }
        }
    }
  }

  List<_ImageGridSlot> _buildSlots() {
    if (images.isEmpty) return const [];

    final slots = <_ImageGridSlot>[];
    final usesEditOverflow = !readOnly && onAdd != null && images.length > _editOverflowThreshold;
    final usesReadOnlyOverflow = readOnly && images.length > _editOverflowThreshold;

    if (usesEditOverflow) {
      for (var i = 0; i < _editOverflowThreshold - 1; i++) {
        slots.add(_ImageGridSlot.image(images[i], index: i));
      }
      slots.add(
        _ImageGridSlot.overflow(
          images[_editOverflowThreshold - 1],
          index: _editOverflowThreshold - 1,
          extraCount: images.length - _editOverflowThreshold,
        ),
      );
      slots.add(const _ImageGridSlot.add());
      return slots;
    }

    if (usesReadOnlyOverflow) {
      for (var i = 0; i < _editOverflowThreshold - 1; i++) {
        slots.add(_ImageGridSlot.image(images[i], index: i));
      }
      slots.add(
        _ImageGridSlot.overflow(
          images[_editOverflowThreshold - 1],
          index: _editOverflowThreshold - 1,
          extraCount: images.length - _editOverflowThreshold,
        ),
      );
      return slots;
    }

    for (var i = 0; i < images.length; i++) {
      slots.add(_ImageGridSlot.image(images[i], index: i));
    }

    if (!readOnly && onAdd != null && images.length < _maxCells) {
      slots.add(const _ImageGridSlot.add());
    }

    return slots;
  }
}

enum _ImageGridSlotKind { image, overflow, add }

class _ImageGridSlot {
  const _ImageGridSlot._({required this.kind, this.item, this.imageIndex, this.extraCount = 0});

  const _ImageGridSlot.image(AppImageItem item, {required int index})
    : this._(kind: _ImageGridSlotKind.image, item: item, imageIndex: index);

  const _ImageGridSlot.overflow(AppImageItem item, {required int index, required int extraCount})
    : this._(kind: _ImageGridSlotKind.overflow, item: item, imageIndex: index, extraCount: extraCount);

  const _ImageGridSlot.add() : this._(kind: _ImageGridSlotKind.add);

  final _ImageGridSlotKind kind;
  final AppImageItem? item;
  final int? imageIndex;
  final int extraCount;
}

class _ImageCell extends StatelessWidget {
  const _ImageCell({required this.slot, required this.readOnly, required this.onTap, this.onRemove});

  final _ImageGridSlot slot;
  final bool readOnly;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return switch (slot.kind) {
      _ImageGridSlotKind.add => _AddTile(onTap: onTap, color: cs.primary),
      _ImageGridSlotKind.image || _ImageGridSlotKind.overflow => Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImageSource.thumbnail(slot.item!),
              if (slot.kind == _ImageGridSlotKind.overflow)
                Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  alignment: Alignment.center,
                  child: Text(
                    '+${slot.extraCount}',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              if (onRemove != null && slot.kind != _ImageGridSlotKind.overflow)
                Positioned(top: 4, right: 4, child: _RemoveButton(onTap: onRemove!)),
            ],
          ),
        ),
      ),
    };
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, required this.color});

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
          ),
          child: Center(child: Icon(Icons.photo_camera_outlined, color: color, size: 32)),
        ),
      ),
    );
  }
}

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState({
    required this.readOnly,
    required this.onAdd,
    required this.color,
    required this.textTheme,
    required this.surfaceColor,
    required this.onSurfaceColor,
    this.placeholder,
  });

  final bool readOnly;
  final VoidCallback? onAdd;
  final Color color;
  final TextTheme textTheme;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (placeholder != null) return placeholder!;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.photo_camera_outlined, size: 40, color: readOnly ? onSurfaceColor.withValues(alpha: 0.35) : color),
        const SizedBox(height: 10),
        Text(
          readOnly
              ? 'No images.'
              : onAdd != null
              ? 'Tap to capture a photo'
              : 'No images yet.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: onSurfaceColor.withValues(alpha: 0.65)),
        ),
      ],
    );

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: readOnly ? null : onAdd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Center(child: content),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
        child: const Icon(Icons.close, size: 16, color: Colors.white),
      ),
    );
  }
}

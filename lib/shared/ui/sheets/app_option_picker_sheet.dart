import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Shows a selectable option list inside [showAppBottomSheet].
Future<T?> showAppOptionPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T option) label,
  String? subtitle,
  bool Function(T option)? isSelected,
  AppBottomSheetPreset preset = AppBottomSheetPreset.auto,
}) {
  if (options.isEmpty) return Future.value();

  return showAppBottomSheet<T>(
    context: context,
    title: title,
    subtitle: subtitle,
    itemCount: options.length,
    preset: preset,
    builder: (context, scrollController) {
      final tiles = [
        for (final option in options)
          _OptionTile<T>(
            label: label(option),
            selected: isSelected?.call(option) ?? false,
            onTap: () => Navigator.of(context).pop(option),
          ),
      ];

      if (scrollController != null) {
        return ListView.separated(
          controller: scrollController,
          itemCount: tiles.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) => tiles[index],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            tiles[i],
          ],
        ],
      );
    },
  );
}

class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? cs.primaryContainer.withValues(alpha: 0.45) : cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: selected ? 0.95 : 0.82),
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_rounded, color: cs.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

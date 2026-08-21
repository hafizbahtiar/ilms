import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/app/environment/environment_controller.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';

const _segmentOrder = [AppFlavor.dev, AppFlavor.stg, AppFlavor.prod];

/// Caps how wide the switcher grows on large screens (e.g. tablets/desktop)
/// so it doesn't stretch into an oversized, awkward-looking pill.
const _maxTrackWidth = 280.0;

class EnvironmentSwitcher extends ConsumerWidget {
  const EnvironmentSwitcher({super.key});

  static String _label(AppFlavor flavor) => flavor.name.toUpperCase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(environmentControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final selectedIndex = _segmentOrder.indexOf(current);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxTrackWidth),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / _segmentOrder.length;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: segmentWidth * selectedIndex,
                    width: segmentWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  Row(
                    children: [
                      for (final flavor in _segmentOrder)
                        Expanded(
                          child: _EnvironmentSegment(
                            label: _label(flavor),
                            selected: flavor == current,
                            selectedColor: cs.onPrimary,
                            unselectedColor: cs.onSurface.withValues(alpha: 0.6),
                            onTap: () => _onSelect(context, ref, flavor),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onSelect(BuildContext context, WidgetRef ref, AppFlavor flavor) async {
    if (flavor == ref.read(environmentControllerProvider)) return;

    await ref.read(environmentControllerProvider.notifier).setFlavor(flavor);

    if (context.mounted) {
      AppSnackbar.info(context, 'Switched to ${_label(flavor)} environment.');
    }
  }
}

class _EnvironmentSegment extends StatelessWidget {
  const _EnvironmentSegment({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? selectedColor : unselectedColor,
              letterSpacing: 0.5,
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

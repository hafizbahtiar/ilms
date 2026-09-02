import 'package:flutter/material.dart';

/// Shortcut tile used on the home screen module grids.
class HomeModuleButton extends StatelessWidget {
  const HomeModuleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.badgeCount,
    this.enabled = true,
  });

  static const tileHeight = 112.0;
  static const iconBoxSize = 44.0;

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tileColor = cs.surfaceContainerHigh;
    final effectiveAccent = enabled ? _readableAccent(cs, accentColor) : cs.onSurface.withValues(alpha: 0.38);

    return Material(
      color: tileColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: tileHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        color: effectiveAccent.withValues(alpha: enabled ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 22, color: effectiveAccent),
                    ),
                    if (badgeCount != null && badgeCount! > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.error,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: tileColor, width: 1.5),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            badgeCount! > 99 ? '99+' : '$badgeCount',
                            textAlign: TextAlign.center,
                            style: textTheme.labelSmall?.copyWith(color: cs.onError, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: cs.onSurface.withValues(alpha: enabled ? 0.88 : 0.45),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navy icons vanish on charcoal. In dark mode the lamp is yellow —
  /// the 10% accent — so home tiles stay readable without a periwinkle wash.
  static Color _readableAccent(ColorScheme cs, Color accent) {
    if (cs.brightness != Brightness.dark) return accent;
    if (ThemeData.estimateBrightnessForColor(accent) == Brightness.light) {
      return accent;
    }
    return cs.secondary;
  }
}

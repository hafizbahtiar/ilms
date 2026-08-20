import 'package:flutter/material.dart';

export 'app_bottom_sheet_action_bar.dart';

/// Preset sizing for [showAppBottomSheet].
enum AppBottomSheetPreset {
  /// Short content — wraps height, capped around 50% of the screen.
  compact,

  /// Long / scrollable content — starts around 55%, draggable to near-fullscreen.
  scrollable,

  /// Picks [compact] when [itemCount] <= 4, otherwise [scrollable].
  auto,
}

typedef AppBottomSheetContentBuilder = Widget Function(BuildContext context, ScrollController? scrollController);

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required AppBottomSheetContentBuilder builder,
  Widget? header,
  String? title,
  String? subtitle,
  Widget? leading,
  Widget? trailing,
  Widget? bottomBar,
  AppBottomSheetPreset preset = AppBottomSheetPreset.auto,
  int itemCount = 0,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  bool showCloseButton = true,
  bool useRootNavigator = false,
  bool useSafeArea = true,
}) {
  final resolvedPreset = preset == AppBottomSheetPreset.auto
      ? (itemCount <= 4 ? AppBottomSheetPreset.compact : AppBottomSheetPreset.scrollable)
      : preset;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    useSafeArea: false,
    builder: (context) {
      return _AppBottomSheetShell(
        preset: resolvedPreset,
        header: header,
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        bottomBar: bottomBar,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        useSafeArea: useSafeArea,
        builder: builder,
      );
    },
  );
}

class _AppBottomSheetShell extends StatelessWidget {
  const _AppBottomSheetShell({
    required this.preset,
    required this.builder,
    this.header,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottomBar,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.useSafeArea = true,
  });

  final AppBottomSheetPreset preset;
  final AppBottomSheetContentBuilder builder;
  final Widget? header;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottomBar;
  final bool showDragHandle;
  final bool showCloseButton;
  final bool useSafeArea;

  static const _topRadius = BorderRadius.vertical(top: Radius.circular(20));
  static const _compactMaxHeightFactor = 0.5;
  static const _scrollableInitialSize = 0.55;
  static const _scrollableMinSize = 0.35;
  static const _scrollableMaxSize = 0.95;
  static const _scrollableSnapSizes = [_scrollableMinSize, _scrollableInitialSize, _scrollableMaxSize];

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final sheet = Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: switch (preset) {
        AppBottomSheetPreset.compact => _buildCompact(context),
        AppBottomSheetPreset.scrollable => _buildScrollable(context),
        AppBottomSheetPreset.auto => _buildCompact(context),
      },
    );

    if (!useSafeArea) return sheet;

    return SafeArea(top: preset == AppBottomSheetPreset.scrollable, bottom: true, child: sheet);
  }

  Widget _buildCompact(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * _compactMaxHeightFactor;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _BottomSheetSurface(
          borderRadius: _topRadius,
          showDragHandle: showDragHandle,
          expandContent: bottomBar != null,
          header: _buildHeader(context),
          bottomBar: bottomBar,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomBar == null ? 20 : 0),
            child: builder(context, null),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollable(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _scrollableInitialSize,
      minChildSize: _scrollableMinSize,
      maxChildSize: _scrollableMaxSize,
      snap: true,
      snapSizes: _scrollableSnapSizes,
      expand: false,
      builder: (context, scrollController) {
        return _BottomSheetSurface(
          borderRadius: _topRadius,
          showDragHandle: showDragHandle,
          expandContent: true,
          header: _buildHeader(context),
          bottomBar: bottomBar,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomBar == null ? 20 : 0),
            child: builder(context, scrollController),
          ),
        );
      },
    );
  }

  Widget? _buildHeader(BuildContext context) {
    if (header != null) return header;

    final hasTitle = title != null && title!.isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    if (!hasTitle && !hasSubtitle && leading == null && trailing == null) {
      return null;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle)
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                if (hasSubtitle) ...[
                  if (hasTitle) const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.72)),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showCloseButton)
            _BottomSheetCloseButton(onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _BottomSheetCloseButton extends StatelessWidget {
  const _BottomSheetCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: 'Close',
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.close_rounded, color: colorScheme.onSurface.withValues(alpha: 0.72)),
    );
  }
}

class _BottomSheetSurface extends StatelessWidget {
  const _BottomSheetSurface({
    required this.borderRadius,
    required this.child,
    this.header,
    this.bottomBar,
    this.showDragHandle = true,
    this.expandContent = false,
  });

  final BorderRadius borderRadius;
  final Widget child;
  final Widget? header;
  final Widget? bottomBar;
  final bool showDragHandle;
  final bool expandContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background = theme.dialogTheme.backgroundColor ?? colorScheme.surface;

    return Material(
      color: background,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (showDragHandle) const _DragHandle(),
          if (header != null) ...[header!, Divider(height: 1, color: colorScheme.outlineVariant)],
          if (header == null && showDragHandle) const SizedBox(height: 4),
          if (expandContent)
            Expanded(child: child)
          else
            child,
          ?bottomBar,
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}

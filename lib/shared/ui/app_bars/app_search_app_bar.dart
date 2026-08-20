import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable module search app bar with optional search field, filter chips, and filter action.
///
/// Mirrors legacy `CustomSearchAppBar` but uses the app theme. Search and chip rows
/// live in [AppBar.bottom] so status-bar insets are handled correctly.
class AppSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppSearchAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.tailActions,
    this.filterChips = const [],
    this.searchHints = const ['Search...'],
    this.onSearchChanged,
    this.onFilterTap,
    this.onClearFilters,
    this.onChipRemoved,
    this.showResetChip = true,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.centerTitle = false,
    this.elevation,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final List<Widget>? tailActions;
  final List<String> filterChips;
  final List<String> searchHints;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClearFilters;
  final void Function(int index)? onChipRemoved;
  final bool showResetChip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double? elevation;

  static const double searchRowHeight = 44;
  static const double chipRowHeight = 36;

  bool get _hasSearch => onSearchChanged != null;
  bool get _hasChips => filterChips.isNotEmpty;
  bool get _hasBuiltInBottom => _hasSearch || _hasChips;

  @override
  Size get preferredSize {
    var height = kToolbarHeight;
    if (_hasBuiltInBottom) {
      height += _SearchChipBar.preferredHeight(hasSearch: _hasSearch, hasChips: _hasChips);
    }
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = backgroundColor ?? theme.colorScheme.primary;
    final foreground = foregroundColor ?? theme.colorScheme.onPrimary;

    PreferredSizeWidget? resolvedBottom;
    if (_hasBuiltInBottom && bottom != null) {
      resolvedBottom = PreferredSize(
        preferredSize: Size.fromHeight(
          _SearchChipBar.preferredHeight(hasSearch: _hasSearch, hasChips: _hasChips) + bottom!.preferredSize.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchChipBar(
              hasSearch: _hasSearch,
              hasChips: _hasChips,
              searchHints: searchHints,
              filterChips: filterChips,
              onSearchChanged: onSearchChanged,
              onClearFilters: onClearFilters,
              onChipRemoved: onChipRemoved,
              showResetChip: showResetChip,
              foregroundColor: foreground,
            ),
            bottom!,
          ],
        ),
      );
    } else if (_hasBuiltInBottom) {
      resolvedBottom = _SearchChipBar(
        hasSearch: _hasSearch,
        hasChips: _hasChips,
        searchHints: searchHints,
        filterChips: filterChips,
        onSearchChanged: onSearchChanged,
        onClearFilters: onClearFilters,
        onChipRemoved: onChipRemoved,
        showResetChip: showResetChip,
        foregroundColor: foreground,
      );
    } else {
      resolvedBottom = bottom;
    }

    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: background,
      foregroundColor: foreground,
      iconTheme: IconThemeData(color: foreground),
      title: titleWidget ?? (title == null ? null : Text(title!)),
      centerTitle: centerTitle,
      elevation: elevation ?? theme.appBarTheme.elevation ?? 0,
      scrolledUnderElevation: 0,
      actions: [
        ...?actions,
        if (onFilterTap != null)
          _FilterAction(
            activeCount: filterChips.length,
            onTap: onFilterTap!,
            foregroundColor: foreground,
          ),
        ...?tailActions,
        const SizedBox(width: 4),
      ],
      bottom: resolvedBottom,
    );
  }
}

class _SearchChipBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchChipBar({
    required this.hasSearch,
    required this.hasChips,
    required this.searchHints,
    required this.filterChips,
    required this.onSearchChanged,
    required this.onClearFilters,
    required this.onChipRemoved,
    required this.showResetChip,
    required this.foregroundColor,
  });

  final bool hasSearch;
  final bool hasChips;
  final List<String> searchHints;
  final List<String> filterChips;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearFilters;
  final void Function(int index)? onChipRemoved;
  final bool showResetChip;
  final Color foregroundColor;

  static double preferredHeight({required bool hasSearch, required bool hasChips}) {
    var height = 0.0;
    if (hasSearch) height += AppSearchAppBar.searchRowHeight + 8;
    if (hasChips) {
      height += AppSearchAppBar.chipRowHeight + (hasSearch ? 8 : 10) + 12;
    } else if (hasSearch) {
      height += 12;
    }
    return height;
  }

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight(hasSearch: hasSearch, hasChips: hasChips));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              height: AppSearchAppBar.searchRowHeight,
              child: TextField(
                onChanged: onSearchChanged,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                  hintText: searchHints.first,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        if (hasChips)
          Padding(
            padding: EdgeInsets.fromLTRB(16, hasSearch ? 8 : 10, 16, 12),
            child: SizedBox(
              height: AppSearchAppBar.chipRowHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (onClearFilters != null && showResetChip) ...[
                    _ResetChip(onTap: onClearFilters!, foregroundColor: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  for (var i = 0; i < filterChips.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _ActiveChip(
                      label: filterChips[i],
                      foregroundColor: foregroundColor,
                      onRemoved: onChipRemoved != null ? () => onChipRemoved!(i) : null,
                    ),
                  ],
                ],
              ),
            ),
          )
        else if (hasSearch)
          const SizedBox(height: 12),
      ],
    );
  }
}

class _FilterAction extends StatelessWidget {
  const _FilterAction({
    required this.activeCount,
    required this.onTap,
    required this.foregroundColor,
  });

  final int activeCount;
  final VoidCallback onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Filter',
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: activeCount > 0,
        label: Text('$activeCount'),
        child: Icon(Icons.tune_rounded, color: foregroundColor),
      ),
    );
  }
}

class _ResetChip extends StatelessWidget {
  const _ResetChip({required this.onTap, required this.foregroundColor});

  final VoidCallback onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: foregroundColor.withValues(alpha: 0.55)),
          color: foregroundColor.withValues(alpha: 0.12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
            Text(
              'Reset',
              style: TextStyle(color: foregroundColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.foregroundColor,
    this.onRemoved,
  });

  final String label;
  final Color foregroundColor;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: onRemoved != null ? 4 : 10, top: 4, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.35)),
        color: foregroundColor.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: foregroundColor, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          if (onRemoved != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemoved,
              child: Icon(Icons.close_rounded, size: 13, color: foregroundColor.withValues(alpha: 0.75)),
            ),
          ],
        ],
      ),
    );
  }
}

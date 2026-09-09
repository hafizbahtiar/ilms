import 'package:flutter/material.dart';

/// Visual state for [AppListView].
enum AppListState {
  /// Initial / paged fetch in progress with no cached items.
  loading,

  /// Fetch failed.
  error,

  /// Successful fetch with zero items.
  empty,

  /// Items available (may still be loading more at the bottom).
  content,
}

/// Copy and optional action for empty lists.
class AppListEmptyConfig {
  const AppListEmptyConfig({
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// Reusable list scaffold with loading, empty, error, pull-to-refresh, and footer slots.
///
/// Use for search results, drafts, history, or any scrollable module list.
class AppListView extends StatelessWidget {
  const AppListView({
    super.key,
    required this.state,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    this.separatorHeight = 8,
    this.header,
    this.footer,
    this.empty,
    this.errorMessage,
    this.loadingMessage,
    this.onRefresh,
    this.onRetry,
    this.isLoadingMore = false,
    this.shrinkWrap = false,
    this.physics,
    this.gridItemExtent,
  });

  final AppListState state;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final double separatorHeight;
  final Widget? header;
  final Widget? footer;
  final AppListEmptyConfig? empty;
  final String? errorMessage;
  final String? loadingMessage;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;
  final bool isLoadingMore;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  /// Fixed row height for grid cells at wide widths (>= [_gridBreakpoint]).
  ///
  /// When null (default), the list never switches to a grid — it stays a
  /// single, width-capped column even on tablets/landscape, since tile
  /// content of varying height (optional subtitle/leading/trailing) cannot
  /// be safely fit into a fixed grid cell without knowing its extent.
  final double? gridItemExtent;

  static const double _wideBreakpoint = 600;
  static const double _gridBreakpoint = 700;
  static const double _singleColumnMaxWidth = 640;
  static const double _gridMaxWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final resolvedPhysics = physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null);

    Widget body = switch (state) {
      AppListState.loading => _AppListLoading(message: loadingMessage),
      AppListState.error => _AppListError(message: errorMessage, onRetry: onRetry),
      AppListState.empty => _AppListEmpty(config: empty),
      AppListState.content => LayoutBuilder(
        builder: (context, constraints) => _buildList(resolvedPhysics, constraints.maxWidth),
      ),
    };

    if (header != null || footer != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          if (shrinkWrap) body else Expanded(child: body),
          ?footer,
        ],
      );
    }

    if (onRefresh != null && state == AppListState.content) {
      body = RefreshIndicator.adaptive(onRefresh: onRefresh!, child: body);
    }

    return SafeArea(child: body);
  }

  Widget _buildList(ScrollPhysics? resolvedPhysics, double availableWidth) {
    if (itemCount == 0 && !isLoadingMore) {
      return _AppListEmpty(config: empty);
    }

    final useGrid = gridItemExtent != null && availableWidth >= _gridBreakpoint;
    final maxContentWidth = availableWidth < _wideBreakpoint
        ? double.infinity
        : (useGrid ? _gridMaxWidth : _singleColumnMaxWidth);

    final scrollView = CustomScrollView(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: resolvedPhysics,
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: useGrid
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: separatorHeight,
                    crossAxisSpacing: separatorHeight,
                    mainAxisExtent: gridItemExtent,
                  ),
                  delegate: SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
                )
              : SliverList.separated(
                  itemCount: itemCount,
                  separatorBuilder: (_, _) => SizedBox(height: separatorHeight),
                  itemBuilder: itemBuilder,
                ),
        ),
        if (isLoadingMore) const SliverToBoxAdapter(child: _AppListLoadingMore()),
      ],
    );

    if (maxContentWidth.isInfinite) return scrollView;

    return Center(
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxContentWidth), child: scrollView),
    );
  }
}

/// Styled list tile matching app surfaces — optional helper for [AppListView.itemBuilder].
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.dense = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? cs.primaryContainer.withValues(alpha: 0.45) : cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 8 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withValues(alpha: 0.92),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.62)),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppListLoading extends StatelessWidget {
  const _AppListLoading({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppListLoadingMore extends StatelessWidget {
  const _AppListLoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator.adaptive(strokeWidth: 2.5)),
      ),
    );
  }
}

class _AppListError extends StatelessWidget {
  const _AppListError({this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: cs.error.withValues(alpha: 0.85)),
            const SizedBox(height: 12),
            Text(
              message ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppListEmpty extends StatelessWidget {
  const _AppListEmpty({this.config});

  final AppListEmptyConfig? config;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolved = config ?? const AppListEmptyConfig(title: 'No items yet');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(resolved.icon, size: 44, color: cs.onSurface.withValues(alpha: 0.35)),
            const SizedBox(height: 12),
            Text(
              resolved.title,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (resolved.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                resolved.subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.62)),
              ),
            ],
            if (resolved.actionLabel != null && resolved.onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: resolved.onAction, child: Text(resolved.actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

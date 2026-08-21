import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Shows a selectable option list inside [showAppBottomSheet].
///
/// When [options] is empty the sheet still opens with an [empty] state instead
/// of silently doing nothing.
Future<T?> showAppOptionPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T option) label,
  String? subtitle,
  bool Function(T option)? isSelected,
  AppBottomSheetPreset preset = AppBottomSheetPreset.auto,
  AppListEmptyConfig? empty,
}) {
  if (options.isEmpty) {
    return showAppBottomSheet<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      preset: AppBottomSheetPreset.compact,
      builder: (context, scrollController) => AppListView(
        state: AppListState.empty,
        itemCount: 0,
        itemBuilder: (_, _) => const SizedBox.shrink(),
        empty: empty ?? _defaultEmptyConfig(title),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  return showAppBottomSheet<T>(
    context: context,
    title: title,
    subtitle: subtitle,
    itemCount: options.length,
    preset: preset,
    builder: (context, scrollController) {
      return _OptionPickerList<T>(
        options: options,
        label: label,
        isSelected: isSelected,
        scrollController: scrollController,
      );
    },
  );
}

/// Opens the picker immediately, shows a loading state while [loadOptions]
/// resolves, then renders the list or an empty/error state.
///
/// Use for chained lookups (parliament → area → street …) where the fetch can
/// take a moment or legitimately return zero rows for the current parent value.
Future<T?> showAppAsyncOptionPicker<T>({
  required BuildContext context,
  required String title,
  required Future<List<T>> Function() loadOptions,
  required String Function(T option) label,
  String? subtitle,
  bool Function(T option)? isSelected,
  AppBottomSheetPreset preset = AppBottomSheetPreset.scrollable,
  AppListEmptyConfig? empty,
  String? loadingMessage,
}) {
  return showAppBottomSheet<T>(
    context: context,
    title: title,
    subtitle: subtitle,
    preset: preset,
    builder: (context, scrollController) {
      return _AsyncOptionPickerBody<T>(
        loadOptions: loadOptions,
        label: label,
        isSelected: isSelected,
        scrollController: scrollController,
        empty: empty ?? _defaultEmptyConfig(title),
        loadingMessage: loadingMessage ?? 'Loading options…',
      );
    },
  );
}

AppListEmptyConfig _defaultEmptyConfig(String title) {
  return AppListEmptyConfig(
    icon: Icons.search_off_outlined,
    title: 'No $title found',
    subtitle: 'Nothing matches the current selection. Try a different value above.',
  );
}

class _AsyncOptionPickerBody<T> extends StatefulWidget {
  const _AsyncOptionPickerBody({
    required this.loadOptions,
    required this.label,
    required this.isSelected,
    required this.empty,
    required this.loadingMessage,
    this.scrollController,
  });

  final Future<List<T>> Function() loadOptions;
  final String Function(T option) label;
  final bool Function(T option)? isSelected;
  final ScrollController? scrollController;
  final AppListEmptyConfig empty;
  final String loadingMessage;

  @override
  State<_AsyncOptionPickerBody<T>> createState() => _AsyncOptionPickerBodyState<T>();
}

class _AsyncOptionPickerBodyState<T> extends State<_AsyncOptionPickerBody<T>> {
  AppListState _state = AppListState.loading;
  List<T> _options = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = AppListState.loading;
      _errorMessage = null;
    });

    try {
      final options = await widget.loadOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        _state = options.isEmpty ? AppListState.empty : AppListState.content;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _state = AppListState.error;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == AppListState.content) {
      return _OptionPickerList<T>(
        options: _options,
        label: widget.label,
        isSelected: widget.isSelected,
        scrollController: widget.scrollController,
      );
    }

    return AppListView(
      state: _state,
      itemCount: 0,
      itemBuilder: (_, _) => const SizedBox.shrink(),
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      loadingMessage: widget.loadingMessage,
      empty: widget.empty,
      errorMessage: _errorMessage,
      onRetry: _load,
      shrinkWrap: true,
      physics: widget.scrollController == null ? const NeverScrollableScrollPhysics() : null,
    );
  }
}

class _OptionPickerList<T> extends StatelessWidget {
  const _OptionPickerList({
    required this.options,
    required this.label,
    required this.isSelected,
    this.scrollController,
  });

  final List<T> options;
  final String Function(T option) label;
  final bool Function(T option)? isSelected;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.only(top: 10),
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (context, index) => tiles[index],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        for (var i = 0; i < tiles.length; i++) ...[if (i > 0) const SizedBox(height: 4), tiles[i]],
      ],
    );
  }
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

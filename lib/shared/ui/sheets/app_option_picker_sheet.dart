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
  bool searchable = false,
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
        searchable: searchable,
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
  bool searchable = false,
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
        searchable: searchable,
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
    this.searchable = false,
  });

  final Future<List<T>> Function() loadOptions;
  final String Function(T option) label;
  final bool Function(T option)? isSelected;
  final ScrollController? scrollController;
  final AppListEmptyConfig empty;
  final String loadingMessage;
  final bool searchable;

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
        searchable: widget.searchable,
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

class _OptionPickerList<T> extends StatefulWidget {
  const _OptionPickerList({
    required this.options,
    required this.label,
    required this.isSelected,
    this.scrollController,
    this.searchable = false,
  });

  final List<T> options;
  final String Function(T option) label;
  final bool Function(T option)? isSelected;
  final ScrollController? scrollController;
  final bool searchable;

  @override
  State<_OptionPickerList<T>> createState() => _OptionPickerListState<T>();
}

class _OptionPickerListState<T> extends State<_OptionPickerList<T>> {
  final _searchController = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    if (_query.isEmpty) return widget.options;
    final needle = _query.toLowerCase();
    return widget.options.where((option) => widget.label(option).toLowerCase().contains(needle)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final tiles = [
      for (final option in filtered)
        _OptionTile<T>(
          label: widget.label(option),
          selected: widget.isSelected?.call(option) ?? false,
          onTap: () => Navigator.of(context).pop(option),
        ),
    ];

    final searchField = widget.searchable
        ? _SearchField(controller: _searchController, onChanged: _onQueryChanged)
        : null;

    // AnimatedSwitcher gives the empty/results swap a soft cross-fade
    // instead of an abrupt jump-cut as the user types.
    final resultsChild = filtered.isEmpty
        ? _NoMatchesState(key: const ValueKey('empty'), query: _query)
        : (widget.scrollController != null
              ? ListView.separated(
                  key: const ValueKey('list'),
                  controller: widget.scrollController,
                  itemCount: tiles.length,
                  padding: const EdgeInsets.only(top: 10),
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) => tiles[index],
                )
              : Column(
                  key: const ValueKey('list'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    for (var i = 0; i < tiles.length; i++) ...[if (i > 0) const SizedBox(height: 4), tiles[i]],
                  ],
                ));

    final animatedResults = AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: resultsChild);

    if (searchField == null) return resultsChild;

    // With a scrollController (DraggableScrollableSheet path) the results
    // list scrolls the whole sheet, so the search field has to sit outside
    // it as a fixed header. Without one (compact path), everything already
    // shrink-wraps together.
    if (widget.scrollController != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.only(top: 10), child: searchField),
          Expanded(child: animatedResults),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [const SizedBox(height: 10), searchField, animatedResults],
    );
  }

  void _onQueryChanged(String value) => setState(() => _query = value);
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Clear',
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            );
          },
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _NoMatchesState extends StatelessWidget {
  const _NoMatchesState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 28, color: cs.onSurface.withValues(alpha: 0.35)),
            const SizedBox(height: 8),
            Text(
              'No matches for "$query"',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
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

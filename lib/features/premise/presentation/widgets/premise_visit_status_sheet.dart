import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// "Choose Visit Status" step (legacy `PremisSubmitView`) — required by the
/// server on every create/update, shown right before the actual submit call.
///
/// Tapping a status only selects it; the API-triggering submit only happens
/// when the user taps the pinned **Submit** button, so picking a status
/// never fires the network call by itself.
Future<GeneralModel?> showPremiseVisitStatusSheet(BuildContext context, WidgetRef ref, {String? selectedCode}) async {
  final options = await ref.read(premiseVisitStatusesProvider.future);
  if (!context.mounted || options.isEmpty) return null;

  GeneralModel? initial;
  if (selectedCode != null) {
    for (final option in options) {
      if (option.code == selectedCode) {
        initial = option;
        break;
      }
    }
  }
  final selected = ValueNotifier<GeneralModel?>(initial);

  final result = await showAppBottomSheet<GeneralModel>(
    context: context,
    title: 'Choose Visit Status',
    subtitle: 'Select the outcome of this visit, then tap Submit.',
    preset: AppBottomSheetPreset.scrollable,
    bottomBar: ValueListenableBuilder<GeneralModel?>(
      valueListenable: selected,
      builder: (context, value, _) => AppBottomSheetActionBar(
        onPrimary: () => Navigator.of(context).pop(value),
        primaryLabel: 'Submit',
        showSecondary: false,
        primaryEnabled: value != null,
      ),
    ),
    builder: (context, scrollController) {
      return ValueListenableBuilder<GeneralModel?>(
        valueListenable: selected,
        builder: (context, value, _) {
          return ListView.separated(
            controller: scrollController,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = options[index];
              return _VisitStatusTile(
                label: generalLookupLabel(item),
                selected: item.code == value?.code,
                onTap: () => selected.value = item,
              );
            },
          );
        },
      );
    },
  ).unfocusPremiseFormOnComplete(context);

  selected.dispose();
  return result;
}

class _VisitStatusTile extends StatelessWidget {
  const _VisitStatusTile({required this.label, required this.selected, required this.onTap});

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

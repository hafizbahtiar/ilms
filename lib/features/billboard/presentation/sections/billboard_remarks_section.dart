import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/domain/utils/billboard_remark_codec.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

/// Multi-select remark codes with an "Others" free-text follow-up, backed by
/// `resolveRemarkOptions`/`isOtherRemarkOption`. No blocking validation —
/// matches the design doc's "validation stays light" decision.
class BillboardRemarksSection extends ConsumerWidget {
  const BillboardRemarksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final fields = ref.watch(billboardFormFieldsProvider(session));
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final selectedCodes = ref.watch(billboardFormControllerProvider(session).select((s) => s.remark.codes));
    final controller = ref.read(billboardFormControllerProvider(session).notifier);
    final remarksAsync = ref.watch(billboardRemarksProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return remarksAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (error, _) =>
          Text('Unable to load remark options.', style: textTheme.bodySmall?.copyWith(color: cs.error)),
      data: (options) {
        final remarkOptions = options
            .map(
              (item) => BillboardRemarkOption(
                code: item.code ?? '',
                desc: item.desc ?? '',
                display: generalLookupLabel(item),
              ),
            )
            .where((option) => option.code.isNotEmpty)
            .toList();
        final selectedOptions = remarkOptions.where((option) => selectedCodes.contains(option.code)).toList();
        final showOthers = selectedOptions.any((option) => option.isOther);

        Future<void> openPicker() async {
          final applied = await showAppMultiOptionPicker<BillboardRemarkOption>(
            context: context,
            title: 'Remarks',
            options: remarkOptions,
            label: (option) => option.display,
            initialSelected: selectedOptions,
            searchable: remarkOptions.length > 6,
          );
          if (applied != null) {
            controller.setRemarkCodes(applied.map((option) => option.code).toList());
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (remarkOptions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  'No remark options available.',
                  style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                ),
              )
            else if (selectedOptions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  'No remarks selected yet.',
                  style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                ),
              )
            else
              AppSelectedValuesWrap(values: [for (final option in selectedOptions) option.display]),
            if (!readOnly && remarkOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: openPicker,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: Text(selectedOptions.isEmpty ? 'Select Remarks' : 'Edit Remarks'),
              ),
            ],
            if (showOthers) ...[
              const SizedBox(height: 8),
              AppTextField(
                label: 'Other Remarks',
                controller: fields.otherRemarkText,
                readOnly: readOnly,
                maxLines: 3,
                onChanged: controller.setOtherRemarkText,
              ),
            ],
          ],
        );
      },
    );
  }
}

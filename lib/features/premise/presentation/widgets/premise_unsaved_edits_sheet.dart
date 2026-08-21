import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Lists every premise record with a pending local unsaved edit (opened via
/// view → Edit, saved locally, not yet re-submitted). Reusable — not wired
/// to a trigger yet; call this from wherever the entry point ends up being.
///
/// Tapping a row closes the sheet and opens that record via the view→edit
/// resume flow, restoring the saved local changes. Each row also has a
/// Discard action that deletes the local edit without leaving the sheet.
Future<void> showPremiseUnsavedEditsSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    title: 'Unsaved Edits',
    subtitle: 'Local changes to existing premises that haven\'t been re-submitted yet.',
    preset: AppBottomSheetPreset.scrollable,
    builder: (sheetContext, scrollController) {
      return _UnsavedEditsSheetBody(
        scrollController: scrollController,
        onOpenItem: (visitNo) {
          Navigator.of(sheetContext).pop();
          if (context.mounted) context.push(AppRoutes.premiseFormView(visitNo));
        },
      );
    },
  );
}

class _UnsavedEditsSheetBody extends ConsumerWidget {
  const _UnsavedEditsSheetBody({required this.onOpenItem, this.scrollController});

  final ValueChanged<String> onOpenItem;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(premiseEditSessionListProvider);

    return itemsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (_, _) => const _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load unsaved edits',
        subtitle: 'Please try again.',
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.edit_note_rounded,
            title: 'No unsaved edits',
            subtitle: 'Local changes to existing premises will show up here.',
          );
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final visitNo = item.visitNo;
            return _UnsavedEditTile(
              item: item,
              onTap: visitNo == null ? null : () => onOpenItem(visitNo),
              onDiscard: () => _confirmDiscard(context, ref, item),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDiscard(BuildContext context, WidgetRef ref, PremiseDraftSummary item) async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Discard unsaved changes?',
      message: 'This will remove your local edits for "${item.displayTitle}". The saved record itself is unaffected.',
      confirmLabel: 'Discard',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(premiseDraftRepositoryProvider).deleteDraft(item.id);
    if (!context.mounted) return;
    AppSnackbar.success(context, 'Changes discarded.');
  }
}

class _UnsavedEditTile extends StatelessWidget {
  const _UnsavedEditTile({required this.item, required this.onTap, required this.onDiscard});

  final PremiseDraftSummary item;
  final VoidCallback? onTap;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: cs.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.displaySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.undo_rounded, color: cs.error, size: 20),
                tooltip: 'Discard changes',
                onPressed: onDiscard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: cs.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

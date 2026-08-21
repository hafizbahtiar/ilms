import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

enum _DraftAction { duplicate, delete }

class PremiseDraftsPage extends ConsumerWidget {
  const PremiseDraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(premiseDraftsAndEditSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premise Drafts'), centerTitle: false),
      body: itemsAsync.when(
        loading: () => const AppListView(state: AppListState.loading, itemCount: 0, itemBuilder: _noop),
        error: (_, _) => AppListView(
          state: AppListState.error,
          itemCount: 0,
          itemBuilder: _noop,
          errorMessage: 'Unable to load drafts.',
          onRetry: () => ref.invalidate(premiseDraftsAndEditSessionsProvider),
        ),
        data: (items) => AppListView(
          state: items.isEmpty ? AppListState.empty : AppListState.content,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _DraftTile(
              item: item,
              onOpen: () => _openItem(context, item),
              onMore: () => _showItemActions(context, ref, item),
            );
          },
          empty: const AppListEmptyConfig(
            icon: Icons.drafts_outlined,
            title: 'No drafts or unsaved edits yet',
            subtitle: 'Start a new premise entry, or edit an existing one, and save it to see it here.',
          ),
        ),
      ),
    );
  }

  void _openItem(BuildContext context, PremiseDraftSummary item) {
    if (item.isEditSession) {
      final visitNo = item.visitNo;
      if (visitNo == null) return;
      // Routes through the same view→edit resume flow as tapping the
      // record directly — picks the pending local edit back up in edit
      // mode instead of the plain local-draft-id flow.
      context.push(AppRoutes.premiseFormView(visitNo));
      return;
    }
    context.push(AppRoutes.premiseFormDraft(item.id));
  }

  Future<void> _showItemActions(BuildContext context, WidgetRef ref, PremiseDraftSummary item) async {
    final action = await showAppBottomSheet<_DraftAction>(
      context: context,
      title: item.displayTitle,
      subtitle: item.displaySubtitle,
      preset: AppBottomSheetPreset.compact,
      itemCount: item.isEditSession ? 1 : 2,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Duplicating an unsaved edit doesn't make sense — it's a
            // pending change to an existing record, not a reusable
            // template like a new-entry draft.
            if (!item.isEditSession) ...[
              _DraftActionTile(
                icon: Icons.copy_outlined,
                label: 'Duplicate',
                onTap: () => Navigator.of(context).pop(_DraftAction.duplicate),
              ),
              const SizedBox(height: 8),
            ],
            _DraftActionTile(
              icon: item.isEditSession ? Icons.undo_rounded : Icons.delete_outline_rounded,
              label: item.isEditSession ? 'Discard' : 'Delete',
              foregroundColor: cs.error,
              onTap: () => Navigator.of(context).pop(_DraftAction.delete),
            ),
          ],
        );
      },
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case _DraftAction.duplicate:
        await _duplicateDraft(context, ref, item);
      case _DraftAction.delete:
        await _confirmDelete(context, ref, item);
    }
  }

  Future<void> _duplicateDraft(BuildContext context, WidgetRef ref, PremiseDraftSummary item) async {
    try {
      final newId = await ref.read(premiseDraftRepositoryProvider).duplicateDraft(item.id);
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Draft duplicated.');
      context.push(AppRoutes.premiseFormDraft(newId));
    } catch (_) {
      if (!context.mounted) return;
      AppSnackbar.error(context, 'Failed to duplicate draft.');
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, PremiseDraftSummary item) async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: item.isEditSession ? 'Discard unsaved changes?' : 'Delete draft?',
      message: item.isEditSession
          ? 'This will remove your local edits for "${item.displayTitle}". The saved record itself is unaffected.'
          : 'This will permanently remove "${item.displayTitle}".',
      confirmLabel: item.isEditSession ? 'Discard' : 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(premiseDraftRepositoryProvider).deleteDraft(item.id);
    if (!context.mounted) return;
    AppSnackbar.success(context, item.isEditSession ? 'Changes discarded.' : 'Draft deleted.');
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.item, required this.onOpen, required this.onMore});

  final PremiseDraftSummary item;
  final VoidCallback onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppListTile(
      title: item.displayTitle,
      subtitle: item.displaySubtitle,
      leading: Icon(item.isEditSession ? Icons.edit_note_rounded : Icons.storefront_outlined),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypeTag(isEditSession: item.isEditSession, draftType: item.draftType),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurface.withValues(alpha: 0.55)),
            onPressed: onMore,
          ),
        ],
      ),
      onTap: onOpen,
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.isEditSession, required this.draftType});

  final bool isEditSession;
  final PremiseDraftType draftType;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    String label;
    if (isEditSession) {
      bg = cs.errorContainer;
      fg = cs.onErrorContainer;
      label = 'Unsaved';
    } else {
      switch (draftType) {
        case PremiseDraftType.vacant:
          bg = cs.tertiaryContainer;
          fg = cs.onTertiaryContainer;
          label = 'Vacant';
        case PremiseDraftType.duplicate:
          bg = cs.secondaryContainer;
          fg = cs.onSecondaryContainer;
          label = 'Duplicate';
        case PremiseDraftType.newEntry:
          bg = cs.surfaceContainerHighest;
          fg = cs.onSurface.withValues(alpha: 0.7);
          label = 'Draft';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _DraftActionTile extends StatelessWidget {
  const _DraftActionTile({required this.icon, required this.label, required this.onTap, this.foregroundColor});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = foregroundColor ?? cs.onSurface;

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
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _noop(BuildContext context, int index) => const SizedBox.shrink();

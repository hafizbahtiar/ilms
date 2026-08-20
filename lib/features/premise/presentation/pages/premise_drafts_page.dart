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
    final draftsAsync = ref.watch(premiseDraftListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premise Drafts'), centerTitle: false),
      body: draftsAsync.when(
        loading: () => const AppListView(state: AppListState.loading, itemCount: 0, itemBuilder: _noop),
        error: (_, _) => AppListView(
          state: AppListState.error,
          itemCount: 0,
          itemBuilder: _noop,
          errorMessage: 'Unable to load drafts.',
          onRetry: () => ref.invalidate(premiseDraftListProvider),
        ),
        data: (drafts) => AppListView(
          state: drafts.isEmpty ? AppListState.empty : AppListState.content,
          itemCount: drafts.length,
          itemBuilder: (context, index) {
            final draft = drafts[index];
            return _DraftTile(
              draft: draft,
              onOpen: () => context.push(AppRoutes.premiseFormDraft(draft.id)),
              onMore: () => _showDraftActions(context, ref, draft),
            );
          },
          empty: const AppListEmptyConfig(
            icon: Icons.drafts_outlined,
            title: 'No drafts yet',
            subtitle: 'Start a new premise entry and save it as a draft.',
          ),
        ),
      ),
    );
  }

  Future<void> _showDraftActions(BuildContext context, WidgetRef ref, PremiseDraftSummary draft) async {
    final action = await showAppBottomSheet<_DraftAction>(
      context: context,
      title: draft.displayTitle,
      subtitle: draft.displaySubtitle,
      preset: AppBottomSheetPreset.compact,
      itemCount: 2,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _DraftActionTile(
              icon: Icons.copy_outlined,
              label: 'Duplicate',
              onTap: () => Navigator.of(context).pop(_DraftAction.duplicate),
            ),
            const SizedBox(height: 8),
            _DraftActionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
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
        await _duplicateDraft(context, ref, draft);
      case _DraftAction.delete:
        await _confirmDelete(context, ref, draft);
    }
  }

  Future<void> _duplicateDraft(BuildContext context, WidgetRef ref, PremiseDraftSummary draft) async {
    try {
      final newId = await ref.read(premiseDraftRepositoryProvider).duplicateDraft(draft.id);
      if (!context.mounted) return;
      AppSnackbar.success(context, 'Draft duplicated.');
      context.push(AppRoutes.premiseFormDraft(newId));
    } catch (_) {
      if (!context.mounted) return;
      AppSnackbar.error(context, 'Failed to duplicate draft.');
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, PremiseDraftSummary draft) async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete draft?',
      message: 'This will permanently remove "${draft.displayTitle}".',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(premiseDraftRepositoryProvider).deleteDraft(draft.id);
    if (!context.mounted) return;
    AppSnackbar.success(context, 'Draft deleted.');
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.draft, required this.onOpen, required this.onMore});

  final PremiseDraftSummary draft;
  final VoidCallback onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppListTile(
      title: draft.displayTitle,
      subtitle: draft.displaySubtitle,
      leading: const Icon(Icons.storefront_outlined),
      trailing: IconButton(
        icon: Icon(Icons.more_vert_rounded, color: cs.onSurface.withValues(alpha: 0.55)),
        onPressed: onMore,
      ),
      onTap: onOpen,
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

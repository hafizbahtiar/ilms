import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_draft_summary.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_draft_providers.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

class BillboardDraftsPage extends ConsumerWidget {
  const BillboardDraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(billboardDraftsAndEditSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Billboard Drafts'), centerTitle: false),
      body: itemsAsync.when(
        loading: () => const AppListView(state: AppListState.loading, itemCount: 0, itemBuilder: _noop),
        error: (_, _) => AppListView(
          state: AppListState.error,
          itemCount: 0,
          itemBuilder: _noop,
          errorMessage: 'Unable to load drafts.',
          onRetry: () => ref.invalidate(billboardDraftsAndEditSessionsProvider),
        ),
        data: (items) => AppListView(
          state: items.isEmpty ? AppListState.empty : AppListState.content,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _DraftTile(
              item: item,
              onOpen: () => _openItem(context, item),
              onMore: () => _confirmDelete(context, ref, item),
            );
          },
          empty: const AppListEmptyConfig(
            icon: Icons.drafts_outlined,
            title: 'No drafts or unsaved edits yet',
            subtitle: 'Start a new billboard entry, or edit an existing one, and save it to see it here.',
          ),
        ),
      ),
    );
  }

  void _openItem(BuildContext context, BillboardDraftSummary item) {
    if (item.isEditSession) {
      final billboardNo = item.billboardNo;
      if (billboardNo == null) return;
      context.push(AppRoutes.billboardFormView(billboardNo));
      return;
    }
    context.push(AppRoutes.billboardFormDraft(item.id));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, BillboardDraftSummary item) async {
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

    await ref.read(billboardDraftRepositoryProvider).deleteDraft(item.id);
    if (!context.mounted) return;
    AppSnackbar.success(context, item.isEditSession ? 'Changes discarded.' : 'Draft deleted.');
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.item, required this.onOpen, required this.onMore});

  final BillboardDraftSummary item;
  final VoidCallback onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppListTile(
      title: item.displayTitle,
      subtitle: item.displaySubtitle,
      leading: Icon(item.isEditSession ? Icons.edit_note_rounded : Icons.campaign_outlined),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypeTag(isEditSession: item.isEditSession),
          IconButton(
            icon: Icon(
              item.isEditSession ? Icons.undo_rounded : Icons.delete_outline_rounded,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
            onPressed: onMore,
          ),
        ],
      ),
      onTap: onOpen,
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.isEditSession});

  final bool isEditSession;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = isEditSession ? cs.errorContainer : cs.surfaceContainerHighest;
    final fg = isEditSession ? cs.onErrorContainer : cs.onSurface.withValues(alpha: 0.7);
    final label = isEditSession ? 'Unsaved' : 'Draft';

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

Widget _noop(BuildContext context, int index) => const SizedBox.shrink();

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_draft_summary.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_draft_providers.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

class InvestigationDraftsPage extends ConsumerWidget {
  const InvestigationDraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(investigationDraftListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Investigation Drafts'), centerTitle: false),
      body: itemsAsync.when(
        loading: () => const AppListView(state: AppListState.loading, itemCount: 0, itemBuilder: _noop),
        error: (_, _) => AppListView(
          state: AppListState.error,
          itemCount: 0,
          itemBuilder: _noop,
          errorMessage: 'Unable to load drafts.',
          onRetry: () => ref.invalidate(investigationDraftListProvider),
        ),
        data: (items) => AppListView(
          state: items.isEmpty ? AppListState.empty : AppListState.content,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return AppListTile(
              title: item.displayTitle,
              subtitle: item.displaySubtitle,
              leading: const Icon(Icons.edit_note_rounded),
              onTap: () => context.push(AppRoutes.investigationFormEdit(item.investigationNo)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmDiscard(context, ref, item),
              ),
            );
          },
          empty: const AppListEmptyConfig(
            icon: Icons.drafts_outlined,
            title: 'No saved drafts',
            subtitle: 'Edits you Save & Exit while editing an investigation will appear here.',
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscard(BuildContext context, WidgetRef ref, InvestigationDraftSummary item) async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Discard unsaved changes?',
      message: 'This will remove your local edits for "${item.displayTitle}". The saved record itself is unaffected.',
      confirmLabel: 'Discard',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(investigationDraftRepositoryProvider).discardDraft(item.investigationNo);
    if (!context.mounted) return;
    AppSnackbar.success(context, 'Changes discarded.');
  }
}

Widget _noop(BuildContext context, int index) => const SizedBox.shrink();

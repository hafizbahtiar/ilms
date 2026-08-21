import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_status_summary_chart.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/home/home_module_button.dart';
import 'package:ilms/shared/ui/home/home_module_group.dart';

class PremiseHomeSection extends ConsumerWidget {
  const PremiseHomeSection({super.key});

  static final _module = homeModulesById['premise']!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(authControllerProvider).user?.permissions ?? const [];
    if (!permissions.contains(_module.permission)) {
      return const SizedBox.shrink();
    }

    final draftCount = ref.watch(premiseDraftCountProvider).valueOrNull ?? 0;
    final unsavedEditCount = ref.watch(premiseEditSessionCountProvider).valueOrNull ?? 0;
    // The Drafts button opens a page that now lists both new-entry drafts
    // and unsaved edits together (tagged), so its badge should reflect the
    // same combined total rather than just new-entry drafts.
    final draftsPageCount = draftCount + unsavedEditCount;

    return HomeModuleGroup(
      title: _module.title,
      icon: _module.icon,
      color: _module.color,
      prefix: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PremiseHomePrefixRow(),
          SizedBox(height: 12),
          PremiseStatusSummaryChart(),
        ],
      ),
      buttons: [
        HomeModuleButton(
          label: 'View All',
          icon: Icons.list_alt_outlined,
          accentColor: _module.color,
          badgeCount: unsavedEditCount > 0 ? unsavedEditCount : null,
          onTap: () => context.push(AppRoutes.module('premise')),
        ),
        HomeModuleButton(
          label: 'New',
          icon: Icons.add_circle_outline,
          accentColor: _module.color,
          onTap: () => context.push(AppRoutes.premiseFormNewEntry()),
        ),
        HomeModuleButton(
          label: 'Drafts',
          icon: Icons.drafts_outlined,
          accentColor: _module.color,
          badgeCount: draftsPageCount > 0 ? draftsPageCount : null,
          onTap: () => context.push(AppRoutes.premiseDrafts),
        ),
        HomeModuleButton(
          label: 'Duplicate',
          icon: Icons.copy_all_outlined,
          accentColor: _module.color,
          onTap: () => context.push(AppRoutes.premiseDuplicate),
        ),
      ],
    );
  }
}

/// Lays the unsaved-edits quick button to the left of the last-draft card —
/// each hides itself independently, so this collapses entirely when there's
/// neither, and drops the Row (and its spacing) when only one is present.
class _PremiseHomePrefixRow extends ConsumerWidget {
  const _PremiseHomePrefixRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unsavedCount = ref.watch(premiseEditSessionCountProvider).valueOrNull ?? 0;

    if (unsavedCount == 0) return const _PremiseLastDraftCard();

    // No CrossAxisAlignment.stretch: this Row sits in an unbounded-height
    // context (HomeModuleGroup's Column, itself inside the scrollable home
    // page), so stretch would force a tight *infinite* height onto every
    // child — Material's RenderPhysicalShape can't lay out with that. Both
    // children use the same 14px padding + 44px icon box, so they're
    // naturally near-identical heights already without forcing it.
    return Row(children: [const Expanded(child: _PremiseLastDraftCard())]);
  }
}

class _PremiseLastDraftCard extends ConsumerWidget {
  const _PremiseLastDraftCard();

  static final _module = homeModulesById['premise']!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(premiseLatestDraftProvider).valueOrNull;
    if (draft == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: _module.color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _module.color.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.premiseFormDraft(draft.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: HomeModuleButton.iconBoxSize,
                height: HomeModuleButton.iconBoxSize,
                decoration: BoxDecoration(
                  color: _module.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.drafts_outlined, color: _module.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last draft',
                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: _module.color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      draft.displaySubtitle,
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.62)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

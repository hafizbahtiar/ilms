import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_draft_providers.dart';
import 'package:ilms/features/billboard/presentation/widgets/billboard_activity_summary.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/home/home_module_button.dart';
import 'package:ilms/shared/ui/home/home_module_group.dart';

class BillboardHomeSection extends ConsumerWidget {
  const BillboardHomeSection({super.key});

  static final _module = homeModulesById['billboard']!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(authControllerProvider).user?.permissions ?? const [];
    if (!permissions.contains(_module.permission)) {
      return const SizedBox.shrink();
    }

    final accent = Theme.of(context).colorScheme.primary;
    final draftCount = ref.watch(billboardDraftCountProvider).valueOrNull ?? 0;
    final unsavedEditCount = ref.watch(billboardEditSessionCountProvider).valueOrNull ?? 0;
    final draftsPageCount = draftCount + unsavedEditCount;

    return HomeModuleGroup(
      title: _module.title,
      icon: _module.icon,
      color: accent,
      prefix: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [const BillboardActivitySummary(), const SizedBox(height: 12), const _BillboardHomePrefixRow()],
      ),
      buttons: [
        HomeModuleButton(
          label: 'View All',
          icon: Icons.list_alt_outlined,
          accentColor: accent,
          badgeCount: unsavedEditCount > 0 ? unsavedEditCount : null,
          onTap: () => context.push(AppRoutes.billboardList),
        ),
        HomeModuleButton(
          label: 'New Entry',
          icon: Icons.add_circle_outline,
          accentColor: accent,
          onTap: () => context.push(AppRoutes.billboardFormNewEntry()),
        ),
        HomeModuleButton(
          label: 'Drafts',
          icon: Icons.drafts_outlined,
          accentColor: accent,
          badgeCount: draftsPageCount > 0 ? draftsPageCount : null,
          onTap: () => context.push(AppRoutes.billboardDrafts),
        ),
      ],
    );
  }
}

/// Collapses entirely when there's no last draft to show.
class _BillboardHomePrefixRow extends ConsumerWidget {
  const _BillboardHomePrefixRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(billboardLatestDraftProvider).valueOrNull;
    if (draft == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = cs.primary;

    return Material(
      color: accent.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.billboardFormDraft(draft.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: HomeModuleButton.iconBoxSize,
                height: HomeModuleButton.iconBoxSize,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.drafts_outlined, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last draft',
                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: accent),
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

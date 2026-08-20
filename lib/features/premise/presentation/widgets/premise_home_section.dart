import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
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

    return HomeModuleGroup(
      title: _module.title,
      icon: _module.icon,
      color: _module.color,
      prefix: const _PremiseLastDraftCard(),
      buttons: [
        HomeModuleButton(
          label: 'View All',
          icon: Icons.list_alt_outlined,
          accentColor: _module.color,
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
          badgeCount: draftCount > 0 ? draftCount : null,
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

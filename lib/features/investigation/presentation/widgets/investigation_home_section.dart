import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/home/home_module_button.dart';
import 'package:ilms/shared/ui/home/home_module_group.dart';

/// Legacy siasatan's only two working entry points are search and history
/// (no working create flow) — see the feature design doc's non-goals.
class InvestigationHomeSection extends ConsumerWidget {
  const InvestigationHomeSection({super.key});

  static final _module = homeModulesById['investigation']!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(authControllerProvider).user?.permissions ?? const [];
    if (!permissions.contains(_module.permission)) {
      return const SizedBox.shrink();
    }

    final accent = Theme.of(context).colorScheme.primary;

    return HomeModuleGroup(
      title: _module.title,
      icon: _module.icon,
      color: accent,
      buttons: [
        HomeModuleButton(
          label: 'View All',
          icon: Icons.list_alt_outlined,
          accentColor: accent,
          onTap: () => context.push(AppRoutes.investigationListSearch()),
        ),
        HomeModuleButton(
          label: 'History',
          icon: Icons.history_outlined,
          accentColor: accent,
          onTap: () => context.push(AppRoutes.investigationListHistory()),
        ),
      ],
    );
  }
}

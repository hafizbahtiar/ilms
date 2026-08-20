import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/home/home_module_button.dart';
import 'package:ilms/shared/ui/home/home_module_group.dart';

class InvestigationHomeSection extends ConsumerWidget {
  const InvestigationHomeSection({super.key});

  static final _module = homeModulesById['investigation']!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(authControllerProvider).user?.permissions ?? const [];
    if (!permissions.contains(_module.permission)) {
      return const SizedBox.shrink();
    }

    return HomeModuleGroup(
      title: _module.title,
      icon: _module.icon,
      color: _module.color,
      buttons: [
        HomeModuleButton(
          label: 'View All',
          icon: Icons.list_alt_outlined,
          accentColor: _module.color,
          onTap: () => context.push(AppRoutes.module('investigation')),
        ),
        HomeModuleButton(
          label: 'New Case',
          icon: Icons.add_circle_outline,
          accentColor: _module.color,
          enabled: false,
          onTap: () => AppSnackbar.info(context, 'New Case coming soon.'),
        ),
        HomeModuleButton(
          label: 'Open Cases',
          icon: Icons.folder_open_outlined,
          accentColor: _module.color,
          enabled: false,
          onTap: () => AppSnackbar.info(context, 'Open Cases coming soon.'),
        ),
      ],
    );
  }
}

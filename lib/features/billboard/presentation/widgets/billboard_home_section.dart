import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
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

    return HomeModuleGroup(
      title: _module.title,
      icon: _module.icon,
      color: _module.color,
      buttons: [
        HomeModuleButton(
          label: 'View All',
          icon: Icons.list_alt_outlined,
          accentColor: _module.color,
          onTap: () => context.push(AppRoutes.module('billboard')),
        ),
        HomeModuleButton(
          label: 'New Entry',
          icon: Icons.add_circle_outline,
          accentColor: _module.color,
          enabled: false,
          onTap: () => AppSnackbar.info(context, 'New Entry coming soon.'),
        ),
        HomeModuleButton(
          label: 'Map View',
          icon: Icons.map_outlined,
          accentColor: _module.color,
          enabled: false,
          onTap: () => AppSnackbar.info(context, 'Map View coming soon.'),
        ),
      ],
    );
  }
}

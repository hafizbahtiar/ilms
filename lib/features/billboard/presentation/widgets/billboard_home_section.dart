import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          enabled: false,
          // onTap: () => context.push(AppRoutes.module('billboard')),
          onTap: () => AppSnackbar.info(context, 'View All coming soon.'),
        ),
        HomeModuleButton(
          label: 'New Entry',
          icon: Icons.add_circle_outline,
          accentColor: accent,
          enabled: false,
          onTap: () => AppSnackbar.info(context, 'New Entry coming soon.'),
        ),
        HomeModuleButton(
          label: 'Map View',
          icon: Icons.map_outlined,
          accentColor: accent,
          enabled: false,
          onTap: () => AppSnackbar.info(context, 'Map View coming soon.'),
        ),
      ],
    );
  }
}

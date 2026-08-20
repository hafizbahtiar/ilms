import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/home/domain/entities/home_module_item.dart';
import 'package:ilms/features/home/presentation/providers/home_menu_providers.dart';
import 'package:ilms/features/home/presentation/widgets/home_module_group_section.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_card.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _onItemTap(BuildContext context, HomeModuleItem item) {
    final route = item.route;
    if (route == null) {
      AppSnackbar.info(context, '${item.title} coming soon.');
      return;
    }
    context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final groupsAsync = ref.watch(homeMenuGroupsProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (_, _) => Center(
            child: Text('Unable to load modules.', style: textTheme.bodyMedium?.copyWith(color: cs.error)),
          ),
          data: (groups) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Welcome back', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    'Here is your account overview.',
                    style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 20),
                  ProfileCard(user: user, onTap: () => context.push(AppRoutes.profile)),
                  if (groups.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Modules', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    for (final group in groups)
                      HomeModuleGroupSection(group: group, onItemTap: (item) => _onItemTap(context, item)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

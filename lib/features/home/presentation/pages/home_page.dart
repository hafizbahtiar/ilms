import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/billboard/presentation/widgets/billboard_home_section.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_home_section.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_home_section.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_card.dart';
import 'package:ilms/shared/constants/home_modules.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visibleModules = homeModulesForPermissions(user.permissions);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
              if (visibleModules.isNotEmpty) ...[
                const SizedBox(height: 16),
                const PremiseHomeSection(),
                const BillboardHomeSection(),
                const InvestigationHomeSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

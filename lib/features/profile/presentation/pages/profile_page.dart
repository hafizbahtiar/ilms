import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/app/theme/theme_mode_controller.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';
import 'package:ilms/features/profile/presentation/providers/profile_providers.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authControllerProvider).user;
    final profileState = ref.watch(profileControllerProvider);

    if (authUser == null) {
      return const Scaffold(body: Center(child: Text('No profile data available.')));
    }

    if (profileState.isLoading && profileState.profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (profileState.errorMessage != null && profileState.profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(profileState.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.read(profileControllerProvider.notifier).fetchProfile();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No profile data available.')));
    }

    return _ProfileContent(profile: profile, authUser: authUser);
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile, required this.authUser});

  final ProfileUser profile;
  final AuthUser authUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = profileDisplayNameFromProfile(profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(displayName: displayName, email: profile.email, roles: authUser.roles),
              const SizedBox(height: 24),
              Text('Account', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ProfileInfoRow(icon: Icons.person_outline, label: 'Name', value: displayName),
                      Divider(color: cs.outlineVariant),
                      ProfileInfoRow(
                        icon: Icons.alternate_email,
                        label: 'Email',
                        value: profile.email.isNotEmpty ? profile.email : '-',
                      ),
                      if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                        Divider(color: cs.outlineVariant),
                        ProfileInfoRow(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone!),
                      ],
                      Divider(color: cs.outlineVariant),
                      ProfileInfoRow(icon: Icons.badge_outlined, label: 'Role', value: profileRoleLabel(authUser)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Access', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: authUser.permissions.isEmpty
                      ? Text(
                          'No module permissions assigned.',
                          style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final permission in authUser.permissions)
                              ProfilePermissionChip(label: profilePermissionLabel(permission)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Settings', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ProfileSettingTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () => context.push(AppRoutes.changePassword),
                      ),
                      Divider(color: cs.outlineVariant),
                      ProfileSettingTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme',
                        subtitle: 'Choose how the app looks',
                        trailing: themeModeLabel(ref.watch(themeModeControllerProvider)),
                        onTap: () => _showThemeBottomSheet(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => _showLogoutBottomSheet(context, ref),
                child: Text(
                  'Log out',
                  style: TextStyle(color: cs.error, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showThemeBottomSheet(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(themeModeControllerProvider.notifier);
    final current = ref.read(themeModeControllerProvider);

    await showAppBottomSheet<void>(
      context: context,
      preset: AppBottomSheetPreset.compact,
      title: 'Theme',
      subtitle: 'Choose how the app looks',
      itemCount: themeModeOptions().length,
      builder: (context, scrollController) {
        return RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (selected) {
            if (selected != null) {
              controller.setMode(selected);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in themeModeOptions())
                RadioListTile<ThemeMode>(
                  value: mode,
                  secondary: Icon(_themeModeIcon(mode)),
                  title: Text(themeModeLabel(mode)),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogoutBottomSheet(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showAppBottomSheet<bool>(
      context: context,
      preset: AppBottomSheetPreset.compact,
      title: 'Log out',
      subtitle: 'Are you sure you want to log out?',
      builder: (context, scrollController) {
        final cs = Theme.of(context).colorScheme;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log out'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      ref.read(authControllerProvider.notifier).logout();
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.displayName, required this.email, required this.roles});

  final String displayName;
  final String email;
  final List<String> roles;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initials = _initials(displayName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: cs.primary.withValues(alpha: 0.12),
              child: Text(
                initials,
                style: textTheme.headlineSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
              ),
            ],
            if (roles.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final role in roles)
                    Chip(
                      label: Text(role, style: const TextStyle(fontWeight: FontWeight.w700)),
                      backgroundColor: cs.secondary.withValues(alpha: 0.35),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

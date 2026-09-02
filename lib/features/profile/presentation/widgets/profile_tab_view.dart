import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/app/theme/text_scale.dart';
import 'package:ilms/app/theme/text_scale_controller.dart';
import 'package:ilms/app/theme/theme_mode_controller.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/shared/ui/app_version_label.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_state.dart';
import 'package:ilms/features/profile/presentation/providers/profile_providers.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Profile content for the "Profile" tab on the home page — no `Scaffold`
/// or `AppBar` of its own; the home page's shared sliver app bar + tab bar
/// covers that.
class ProfileTabView extends ConsumerStatefulWidget {
  const ProfileTabView({super.key, this.tabController, this.tabIndex = 1});

  final TabController? tabController;
  final int tabIndex;

  @override
  ConsumerState<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends ConsumerState<ProfileTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.tabController?.addListener(_handleTabChange);
    Future<void>.microtask(_loadProfileIfNeeded);
  }

  @override
  void didUpdateWidget(covariant ProfileTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController?.removeListener(_handleTabChange);
      widget.tabController?.addListener(_handleTabChange);
    }
  }

  @override
  void dispose() {
    widget.tabController?.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    final controller = widget.tabController;
    if (controller == null || controller.indexIsChanging) return;
    if (controller.index == widget.tabIndex) {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    }
  }

  void _loadProfileIfNeeded() {
    final state = ref.read(profileControllerProvider);
    if (state.profile == null && !state.isLoading) {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authUser = ref.watch(authControllerProvider).user;
    final profileState = ref.watch(profileControllerProvider);

    // Top is already covered by the home page's shared sliver app bar + tab
    // bar — only the bottom (gesture-nav inset) needs guarding here.
    return SafeArea(
      top: false,
      child: _ProfileBody(authUser: authUser, profileState: profileState),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.authUser, required this.profileState});

  final AuthUser? authUser;
  final ProfileState profileState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (authUser == null) {
      return const Center(child: Text('No profile data available.'));
    }

    if (profileState.isLoading && profileState.profile == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (profileState.errorMessage != null && profileState.profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(profileControllerProvider.notifier).fetchProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return const Center(child: Text('No profile data available.'));
    }

    return _ProfileContent(profile: profile, authUser: authUser!);
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            displayName: displayName,
            email: profile.email,
            roles: authUser.roles,
            envName: _readEnvName(),
          ),
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
                  Divider(color: cs.outlineVariant),
                  ProfileSettingTile(
                    icon: Icons.format_size,
                    title: 'Text size',
                    subtitle: 'Adjust reading comfort',
                    trailing: textScaleLabel(ref.watch(textScaleControllerProvider)),
                    onTap: () => _showTextScaleBottomSheet(context, ref),
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
          const SizedBox(height: 20),
          const AppVersionLabel(),
        ],
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

  Future<void> _showTextScaleBottomSheet(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(textScaleControllerProvider.notifier);
    final current = ref.read(textScaleControllerProvider);

    await showAppBottomSheet<void>(
      context: context,
      preset: AppBottomSheetPreset.compact,
      title: 'Text size',
      subtitle: 'Adjust reading comfort',
      itemCount: textScaleOptions().length,
      builder: (context, scrollController) {
        return RadioGroup<AppTextScale>(
          groupValue: current,
          onChanged: (selected) {
            if (selected != null) {
              controller.setScale(selected);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final scale in textScaleOptions())
                RadioListTile<AppTextScale>(
                  value: scale,
                  secondary: Icon(_textScaleIcon(scale)),
                  title: Text(textScaleLabel(scale)),
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

  IconData _textScaleIcon(AppTextScale scale) {
    return switch (scale) {
      AppTextScale.small => Icons.text_decrease_outlined,
      AppTextScale.medium => Icons.text_fields_outlined,
      AppTextScale.large => Icons.text_increase_outlined,
      AppTextScale.extraLarge => Icons.format_size,
    };
  }

  IconData _themeModeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
  }

  String _readEnvName() {
    try {
      return AppConfig.instance.envName;
    } catch (_) {
      return 'dev';
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.displayName, required this.email, required this.roles, required this.envName});

  final String displayName;
  final String email;
  final List<String> roles;
  final String envName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initials = _initials(displayName);

    // Same gradient-hero language as the premise detail header — a plain
    // white Card here read as a form, not a profile.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(color: cs.secondary, width: 2.5),
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                'assets/profile.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Text(
                  initials,
                  style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.82)),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final role in roles) _HeaderPill(icon: Icons.badge_outlined, label: role),
              _HeaderPill(icon: Icons.hub_outlined, label: envName.toUpperCase(), accent: cs.secondary),
            ],
          ),
        ],
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

/// Chip on the profile gradient header — a status dot in [accent] when set
/// (the env pill), or a plain icon otherwise (role pills).
class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label, this.accent});

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final dotOrIcon = accent != null
        ? Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          )
        : Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dotOrIcon,
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_widgets.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.user, this.onTap, this.envName});

  final AuthUser user;
  final VoidCallback? onTap;
  final String? envName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName = profileDisplayNameFromAuth(user);
    final initials = _initials(displayName);
    final resolvedEnv = envName ?? _readEnvName();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(color: cs.primaryContainer),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarBadge(initials: initials),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                          ),
                          if (user.email.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.alternate_email_rounded,
                                  size: 16,
                                  color: cs.onSurface.withValues(alpha: 0.45),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    user.email,
                                    style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.68)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.35)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final role in user.roles)
                      _ProfileMetaChip(label: _formatRoleLabel(role), icon: Icons.badge_outlined, tone: _ChipTone.role),
                    if (user.roles.isEmpty)
                      _ProfileMetaChip(
                        label: profileRoleLabel(user),
                        icon: Icons.person_outline,
                        tone: _ChipTone.neutral,
                      ),
                    _ProfileMetaChip(
                      label: resolvedEnv.toUpperCase(),
                      icon: Icons.hub_outlined,
                      tone: _envTone(resolvedEnv),
                      showStatusDot: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _readEnvName() {
    try {
      return AppConfig.instance.envName;
    } catch (_) {
      return 'dev';
    }
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  String _formatRoleLabel(String role) {
    return role
        .trim()
        .split(RegExp(r'[\s_-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withValues(alpha: 0.18), cs.primary.withValues(alpha: 0.08)],
        ),
        border: Border.all(color: cs.secondary, width: 2),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

enum _ChipTone { role, neutral, envDev, envStg, envProd }

_ChipTone _envTone(String envName) {
  return switch (envName.toLowerCase()) {
    'dev' => _ChipTone.envDev,
    'stg' => _ChipTone.envStg,
    _ => _ChipTone.envProd,
  };
}

extension _ChipToneColors on _ChipTone {
  ({Color background, Color foreground, Color border}) colors(ColorScheme cs) {
    return switch (this) {
      _ChipTone.role => (
        background: cs.primary.withValues(alpha: 0.1),
        foreground: const Color(0xFF2563EB),
        border: const Color(0x663B82F6),
      ),
      _ChipTone.neutral => (
        background: cs.onSurface.withValues(alpha: 0.06),
        foreground: cs.onSurface.withValues(alpha: 0.72),
        border: cs.outlineVariant,
      ),
      _ChipTone.envDev => (
        background: const Color(0x143B82F6),
        foreground: const Color(0xFF2563EB),
        border: const Color(0x663B82F6),
      ),
      _ChipTone.envStg => (
        background: const Color(0x14F97316),
        foreground: const Color(0xFFEA580C),
        border: const Color(0x66F97316),
      ),
      _ChipTone.envProd => (
        background: cs.secondary.withValues(alpha: 0.28),
        foreground: const Color(0xFF111827),
        border: cs.secondary.withValues(alpha: 0.7),
      ),
    };
  }
}

class _ProfileMetaChip extends StatelessWidget {
  const _ProfileMetaChip({required this.label, required this.icon, required this.tone, this.showStatusDot = false});

  final String label;
  final IconData icon;
  final _ChipTone tone;
  final bool showStatusDot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final palette = tone.colors(cs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showStatusDot)
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: palette.foreground, shape: BoxShape.circle),
            )
          else
            Icon(icon, size: 14, color: palette.foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: palette.foreground, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

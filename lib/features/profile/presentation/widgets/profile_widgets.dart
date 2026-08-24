import 'package:flutter/material.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/profile/domain/entities/profile_user.dart';

class ProfileSettingTile extends StatelessWidget {
  const ProfileSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ],
              ),
            ),
            if (trailing != null && trailing!.isNotEmpty) ...[
              Text(
                trailing!,
                style: textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: cs.primary), const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePermissionChip extends StatelessWidget {
  const ProfilePermissionChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

String profileDisplayNameFromProfile(ProfileUser profile) {
  if (profile.name.trim().isNotEmpty) return profile.name.trim();
  return profile.email.trim().isNotEmpty ? profile.email : '-';
}

String profileRoleLabel(AuthUser user) {
  if (user.roles.isEmpty) return 'No role assigned';
  return user.roles.join(', ');
}

String profilePermissionLabel(String permission) {
  return switch (permission) {
    'view-mobile-premise' => 'Premise Census',
    'view-mobile-billboard' => 'Billboard Census',
    'view-mobile-investigation' => 'Investigation Census',
    _ => permission,
  };
}

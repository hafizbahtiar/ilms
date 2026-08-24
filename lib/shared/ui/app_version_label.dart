import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/services/app_info_provider.dart';

/// Muted "vX.Y.Z (build)" footer — used on the login and profile pages.
/// Hides itself while [packageInfoProvider] is still loading or failed,
/// since a missing version label isn't worth an error state.
class AppVersionLabel extends ConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider).valueOrNull;
    if (packageInfo == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Text(
      packageInfo.versionLabel,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
    );
  }
}

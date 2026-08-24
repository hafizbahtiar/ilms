import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App package metadata (version, build number) — read once from the
/// platform and cached by Riverpod for the app's lifetime.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

extension AppVersionLabel on PackageInfo {
  /// e.g. `"v1.4.2 (108)"`.
  String get versionLabel => 'v$version ($buildNumber)';
}

import 'dart:convert';

import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/services/crash_log/crash_log_local_store.dart';
import 'package:ilms/core/services/crash_log/crash_log_repository.dart';
import 'package:ilms/core/services/crash_log/mobile_error_log.dart';
import 'package:ilms/core/services/device_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Builds a [MobileErrorLog] and sends it to the backend.
///
/// Never throws: failed sends are persisted locally for a later retry.
class CrashLogService {
  CrashLogService({
    CrashLogRepository? repository,
    CrashLogLocalStore? localStore,
    PackageInfo? packageInfo,
  }) : _repository = repository ?? CrashLogRepository(),
       _localStore = localStore ?? CrashLogLocalStore(AppDatabase.instance),
       _packageInfo = packageInfo;

  final CrashLogRepository _repository;
  final CrashLogLocalStore _localStore;
  PackageInfo? _packageInfo;

  Future<void> reportError({
    required String module,
    String? page,
    required String type,
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final packageInfo = await _resolvePackageInfo();
    final log = MobileErrorLog(
      module: module,
      page: page,
      type: type,
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      deviceModel: DeviceInfoService.deviceModel,
      deviceOS: DeviceInfoService.deviceOS,
      deviceOSVersion: DeviceInfoService.deviceOSVersion,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
      timestamp: DateTime.now().toIso8601String(),
    );

    try {
      await _repository.send(log);
    } catch (_) {
      await _localStore.insert(payload: jsonEncode(log.toJson()));
    }
  }

  Future<PackageInfo> _resolvePackageInfo() async {
    return _packageInfo ??= await PackageInfo.fromPlatform();
  }
}

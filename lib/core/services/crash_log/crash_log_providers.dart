import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/local_storage_providers.dart';
import 'package:ilms/core/services/crash_log/crash_log_local_store.dart';
import 'package:ilms/core/services/crash_log/crash_log_retry_controller.dart';
import 'package:ilms/core/services/crash_log/crash_log_service.dart';

final crashLogLocalStoreProvider = Provider<CrashLogLocalStore>((ref) {
  return CrashLogLocalStore(ref.watch(appDatabaseProvider));
});

final crashLogServiceProvider = Provider<CrashLogService>((ref) {
  return CrashLogService(localStore: ref.watch(crashLogLocalStoreProvider));
});

final crashLogRetryControllerProvider = ChangeNotifierProvider<CrashLogRetryController>((ref) {
  final controller = CrashLogRetryController(localStore: ref.watch(crashLogLocalStoreProvider));
  controller.listenConnectivity();
  ref.onDispose(controller.dispose);
  return controller;
});

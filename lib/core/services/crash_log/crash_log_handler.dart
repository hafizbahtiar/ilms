import 'package:flutter/foundation.dart';
import 'package:ilms/core/services/crash_log/crash_log_service.dart';

/// Wires global error handlers to [CrashLogService].
class CrashLogHandler {
  CrashLogHandler._();

  static CrashLogService? _service;

  static void init({CrashLogService? service}) {
    _service = service ?? CrashLogService();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _service?.reportError(
        module: 'general',
        type: 'crash',
        error: details.exception,
        stackTrace: details.stack,
        context: {
          if (details.library != null) 'library': details.library,
          if (details.context != null) 'context': details.context.toString(),
        },
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _service?.reportError(module: 'general', type: 'crash', error: error, stackTrace: stack);
      return true;
    };
  }
}

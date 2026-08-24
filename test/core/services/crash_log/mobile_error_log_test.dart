import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/services/crash_log/mobile_error_log.dart';

void main() {
  group('MobileErrorLog', () {
    test('toJson omits null optional fields', () {
      const log = MobileErrorLog(
        module: 'premis',
        page: '/premisForm',
        type: 'crash',
        message: 'boom',
        deviceModel: 'Pixel 7',
        deviceOS: 'Android',
        deviceOSVersion: 'Android 14',
        appVersion: '1.0.20',
        timestamp: '2026-08-12T10:00:00.000',
      );

      expect(
        log.toJson(),
        {
          'module': 'premis',
          'page': '/premisForm',
          'type': 'crash',
          'message': 'boom',
          'deviceModel': 'Pixel 7',
          'deviceOS': 'Android',
          'deviceOSVersion': 'Android 14',
          'appVersion': '1.0.20',
          'timestamp': '2026-08-12T10:00:00.000',
        },
      );
    });

    test('fromJson round-trips optional fields', () {
      const log = MobileErrorLog(
        module: 'auth',
        type: 'network',
        message: 'timeout',
        stackTrace: 'stack',
        context: {'endpoint': '/api/login'},
        timestamp: '2026-08-12T10:00:00.000',
      );

      final restored = MobileErrorLog.fromJson(log.toJson());

      expect(restored, log);
    });
  });
}

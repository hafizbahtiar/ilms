import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static String deviceModel = 'Unknown';
  static String deviceOS = 'Unknown';
  static String deviceOSVersion = 'Unknown';

  static Future<void> init() async {
    final plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      deviceModel = info.model;
      deviceOS = 'Android';
      deviceOSVersion = 'Android ${info.version.release}';
      return;
    }

    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      deviceModel = info.model;
      deviceOS = 'iOS';
      deviceOSVersion = 'iOS ${info.systemVersion}';
    }
  }
}

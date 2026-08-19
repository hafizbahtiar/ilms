import 'package:flutter/widgets.dart';

import '../core/config/app_config.dart';
import '../core/config/app_flavor.dart';
import '../core/network/dio_client.dart';
import '../flavors.dart' as flavors;
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init(flavor: AppFlavor.fromName(flavors.appFlavor));
  DioClient.create(AppConfig.instance);
  runApp(const App());
}

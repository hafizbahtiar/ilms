import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_flavor.dart';

typedef EnvLoader = Future<Map<String, String>> Function(String fileName);

class AppConfig {
  AppConfig._({required this.flavor, required Map<String, String> values}) : _values = Map.unmodifiable(values);

  final AppFlavor flavor;
  final Map<String, String> _values;

  static AppConfig? _instance;

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('AppConfig.init() must be called before use.');
    }
    return config;
  }

  String get envName => get('APP_ENV', fallback: flavor.name);

  String get baseUrl {
    final value = get('BASE_URL').trim();
    if (value.isEmpty) {
      throw StateError('BASE_URL is missing from ${fileNameFor(flavor)}.');
    }
    return value;
  }

  static String fileNameFor(AppFlavor flavor) => '.env.${flavor.name}';

  String get(String key, {String fallback = ''}) => _values[key] ?? fallback;

  static Future<AppConfig> init({required AppFlavor flavor, EnvLoader? loader}) async {
    final fileName = fileNameFor(flavor);
    final values = loader == null ? await _loadFromDotenv(fileName) : await loader(fileName);

    return _instance = AppConfig._(flavor: flavor, values: values);
  }

  static Future<Map<String, String>> _loadFromDotenv(String fileName) async {
    await dotenv.load(fileName: fileName);
    return Map<String, String>.from(dotenv.env);
  }

  static void reset() {
    _instance = null;
    dotenv.clean();
  }
}

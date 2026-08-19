import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';

void main() {
  tearDown(AppConfig.reset);

  test('maps each flavor to its env file', () {
    expect(AppConfig.fileNameFor(AppFlavor.dev), '.env.dev');
    expect(AppConfig.fileNameFor(AppFlavor.stg), '.env.stg');
    expect(AppConfig.fileNameFor(AppFlavor.prod), '.env.prod');
  });

  test('init loads values for the selected flavor', () async {
    await AppConfig.init(
      flavor: AppFlavor.stg,
      loader: (fileName) async {
        expect(fileName, '.env.stg');
        return {'APP_ENV': 'stg', 'API_URL': 'https://stg.example.com'};
      },
    );

    expect(AppConfig.instance.flavor, AppFlavor.stg);
    expect(AppConfig.instance.envName, 'stg');
    expect(AppConfig.instance.get('API_URL'), 'https://stg.example.com');
  });

  test('get returns fallback when a key is missing', () async {
    await AppConfig.init(flavor: AppFlavor.dev, loader: (_) async => {'APP_ENV': 'dev'});

    expect(AppConfig.instance.get('MISSING', fallback: 'none'), 'none');
  });

  test('baseUrl reads BASE_URL from env', () async {
    await AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev', 'BASE_URL': 'https://dev.example.com'},
    );

    expect(AppConfig.instance.baseUrl, 'https://dev.example.com');
  });

  test('baseUrl throws when BASE_URL is missing', () async {
    await AppConfig.init(flavor: AppFlavor.dev, loader: (_) async => {'APP_ENV': 'dev'});

    expect(() => AppConfig.instance.baseUrl, throwsStateError);
  });

  testWidgets('init loads the dotenv asset for a flavor', (tester) async {
    await AppConfig.init(flavor: AppFlavor.prod);

    expect(AppConfig.instance.flavor, AppFlavor.prod);
    expect(AppConfig.instance.envName, 'prod');
  });
}

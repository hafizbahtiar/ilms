import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/environment/environment_controller.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/premise/presentation/providers/premise_status_summary_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
    await AppConfig.init(flavor: AppFlavor.dev);
    DioClient.create(AppConfig.instance);
  });

  tearDown(() {
    AppPreferences.reset();
    AppConfig.reset();
    DioClient.reset();
  });

  test('remote data source is rebuilt when environment changes', () async {
    final container = ProviderContainer();

    final devClient = container.read(dioClientProvider);
    final devDataSource = container.read(premiseStatusSummaryRemoteDataSourceProvider);
    expect(devClient.dio.options.baseUrl, 'https://dev-ilms.fastsystem.com.my');

    await container.read(environmentControllerProvider.notifier).setFlavor(AppFlavor.prod);

    final prodClient = container.read(dioClientProvider);
    final prodDataSource = container.read(premiseStatusSummaryRemoteDataSourceProvider);

    expect(prodClient.dio.options.baseUrl, 'https://ilms.orasyn.com');
    expect(prodClient, isNot(same(devClient)));
    expect(prodDataSource, isNot(same(devDataSource)));

    container.dispose();
  });
}

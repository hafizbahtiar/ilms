import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/core/services/crash_log/crash_log_local_store.dart';
import 'package:ilms/core/services/crash_log/crash_log_repository.dart';
import 'package:ilms/core/services/crash_log/crash_log_service.dart';
import 'package:ilms/core/services/crash_log/mobile_error_log.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FakeCrashLogRepository extends CrashLogRepository {
  FakeCrashLogRepository() : super(formDataBuilder: const FormDataBuilder());

  MobileErrorLog? sent;
  var fail = false;

  @override
  Future<void> send(MobileErrorLog log) async {
    if (fail) {
      throw DioException(
        requestOptions: RequestOptions(path: CrashLogRepository.endpoint),
        type: DioExceptionType.connectionError,
      );
    }
    sent = log;
  }
}

void main() {
  tearDown(() {
    AppConfig.reset();
    DioClient.reset();
    AppDatabase.reset();
  });

  Future<CrashLogLocalStore> createLocalStore() async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await AppDatabase.init(database: database);
    return CrashLogLocalStore(database);
  }

  test('CrashLogRepository POSTs json payload in data form field', () async {
    await AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev', 'BASE_URL': 'https://dev.example.com'},
    );

    RequestOptions? captured;
    final client = DioClient.create(AppConfig.instance);
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(Response<void>(requestOptions: options, statusCode: 200));
        },
      ),
    );

    const log = MobileErrorLog(
      module: 'premis',
      type: 'crash',
      message: 'boom',
      timestamp: '2026-08-12T10:00:00.000',
    );

    await CrashLogRepository().send(log);

    expect(captured?.path, '/api/mobileErrorLog');
    final formData = captured!.data as FormData;
    final fields = {for (final field in formData.fields) field.key: field.value};
    final decoded = jsonDecode(fields['data']!) as Map<String, dynamic>;
    expect(decoded['module'], 'premis');
    expect(decoded['message'], 'boom');
  });

  test('CrashLogService queues logs offline when send fails', () async {
    final localStore = await createLocalStore();
    final repository = FakeCrashLogRepository()..fail = true;
    final service = CrashLogService(
      repository: repository,
      localStore: localStore,
      packageInfo: PackageInfo(
        appName: 'ILMS',
        packageName: 'com.example.ilms',
        version: '1.0.1',
        buildNumber: '1',
      ),
    );

    await service.reportError(module: 'auth', type: 'network', error: StateError('timeout'));

    final pending = await localStore.getPending();
    expect(pending, hasLength(1));
    final payload = jsonDecode(pending.first.payload) as Map<String, dynamic>;
    expect(payload['module'], 'auth');
    expect(payload['message'], contains('timeout'));
  });

  test('CrashLogService sends logs when online', () async {
    final localStore = await createLocalStore();
    final repository = FakeCrashLogRepository();
    final service = CrashLogService(
      repository: repository,
      localStore: localStore,
      packageInfo: PackageInfo(
        appName: 'ILMS',
        packageName: 'com.example.ilms',
        version: '1.0.1',
        buildNumber: '1',
      ),
    );

    await service.reportError(module: 'general', type: 'crash', error: StateError('boom'));

    expect(repository.sent?.module, 'general');
    expect(await localStore.getPending(), isEmpty);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/app/environment/environment_controller.dart';
import 'package:ilms/core/network/dio_client.dart';

/// Exposes the active [DioClient] and rebuilds when the environment changes.
final dioClientProvider = Provider<DioClient>((ref) {
  ref.watch(environmentControllerProvider);
  return DioClient.instance;
});

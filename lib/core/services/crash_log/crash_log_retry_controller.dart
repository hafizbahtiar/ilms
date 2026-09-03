import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/core/services/crash_log/crash_log_local_store.dart';
import 'package:ilms/core/services/crash_log/crash_log_repository.dart';
import 'package:ilms/core/services/crash_log/mobile_error_log.dart';

/// Flushes queued crash logs once connectivity is restored.
class CrashLogRetryController extends ChangeNotifier {
  CrashLogRetryController({CrashLogRepository? repository, required this._localStore, Connectivity? connectivity})
    : _repository = repository ?? CrashLogRepository(),
      _connectivity = connectivity ?? Connectivity();

  final CrashLogRepository _repository;
  final CrashLogLocalStore _localStore;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;
  bool get hasPending => _pendingCount > 0;

  void _logger(String message) => dev.log(message, name: 'CrashLogRetry');

  void listenConnectivity() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      if (hasConnection) {
        _logger('Connectivity restored — flushing queued crash logs');
        flushPending();
      }
    });
  }

  Future<void> refresh() async {
    try {
      final pending = await _localStore.getPending();
      _pendingCount = pending.length;
    } catch (error) {
      _logger('refresh failed :: $error');
    }
    notifyListeners();
  }

  Future<void> flushPending() async {
    final pending = await _localStore.getPending();
    for (final entry in pending) {
      final id = entry.id;
      try {
        final log = MobileErrorLog.fromJson(jsonDecode(entry.payload) as Map<String, dynamic>);
        await _repository.send(log);
        await _localStore.delete(id);
      } catch (error) {
        final message = error is DioException ? extractDioErrorMessage(error) : error.toString();
        await _localStore.incrementRetry(id, errorMessage: message);
      }
    }

    await refresh();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

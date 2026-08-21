import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';
import '../features/auth/presentation/controllers/auth_state.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../shared/lookups/providers/general_lookup_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  var _ready = false;
  var _lookupsWarmedUp = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_restoreSession);
  }

  Future<void> _restoreSession() async {
    await ref.read(authControllerProvider.notifier).tryAutoLogin();
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeControllerProvider);

    // The lookup endpoints require auth — only warm them up once a token
    // actually exists (auto-login success, or a later manual login), never
    // before, or every one of them 401s and gets stuck in an error state
    // (they're `keepAlive`, so nothing retries them automatically).
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.user != null && !_lookupsWarmedUp) {
        _lookupsWarmedUp = true;
        warmUpGeneralLookups(ref);
      }
    });

    final authState = ref.read(authControllerProvider);
    if (authState.user != null && !_lookupsWarmedUp) {
      _lookupsWarmedUp = true;
      warmUpGeneralLookups(ref);
    }

    if (!_ready) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
      );
    }

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'ILMS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/features/auth/presentation/pages/login_page.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/change_password/presentation/pages/change_password_page.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/features/home/presentation/pages/home_page.dart';
import 'package:ilms/features/home/presentation/pages/module_placeholder_page.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/pages/premise_detail_page.dart';
import 'package:ilms/features/premise/presentation/pages/premise_duplicate_page.dart';
import 'package:ilms/features/premise/presentation/pages/premise_drafts_page.dart';
import 'package:ilms/features/premise/presentation/pages/premise_form_page.dart';
import 'package:ilms/features/premise/presentation/pages/premise_list_page.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_state.dart';
import 'package:ilms/features/billboard/presentation/pages/billboard_drafts_page.dart';
import 'package:ilms/features/billboard/presentation/pages/billboard_form_page.dart';
import 'package:ilms/features/billboard/presentation/pages/billboard_list_page.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_form_state.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_list_controller.dart';
import 'package:ilms/features/investigation/presentation/pages/investigation_drafts_page.dart';
import 'package:ilms/features/investigation/presentation/pages/investigation_form_page.dart';
import 'package:ilms/features/investigation/presentation/pages/investigation_list_page.dart';

import 'app_routes.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }

  final Ref ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final user = ref.read(authControllerProvider).user;
    final isLoginRoute = state.matchedLocation == AppRoutes.login;

    if (user == null && !isLoginRoute) {
      return AppRoutes.login;
    }

    if (user != null && isLoginRoute) {
      return AppRoutes.home;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
      GoRoute(path: AppRoutes.changePassword, builder: (context, state) => const ChangePasswordPage()),
      GoRoute(
        path: AppRoutes.premiseForm,
        builder: (context, state) {
          final mode = PremiseFormModeX.fromQuery(state.uri.queryParameters['mode']);
          final localId = int.tryParse(state.uri.queryParameters['localId'] ?? '');
          final instanceKey = state.uri.queryParameters['i'];
          final isVacantIntent = state.uri.queryParameters['vacant'] == 'true';
          final visitNo = state.uri.queryParameters['visitNo'];
          final session = PremiseFormSession(
            mode: mode,
            localDraftId: localId,
            instanceKey: instanceKey,
            isVacantIntent: isVacantIntent,
            visitNo: visitNo,
          );
          return PremiseFormPage(session: session);
        },
      ),
      GoRoute(
        path: AppRoutes.premiseDetail,
        builder: (context, state) {
          final visitNo = state.uri.queryParameters['visitNo'] ?? '';
          return PremiseDetailPage(visitNo: visitNo);
        },
      ),
      GoRoute(path: AppRoutes.premiseDrafts, builder: (context, state) => const PremiseDraftsPage()),
      GoRoute(path: AppRoutes.premiseDuplicate, builder: (context, state) => const PremiseDuplicatePage()),
      GoRoute(
        path: AppRoutes.billboardList,
        builder: (context, state) => BillboardListPage(module: homeModulesById['billboard']!),
      ),
      GoRoute(
        path: AppRoutes.billboardForm,
        builder: (context, state) {
          final mode = BillboardFormModeX.fromQuery(state.uri.queryParameters['mode']);
          final localId = int.tryParse(state.uri.queryParameters['localId'] ?? '');
          final instanceKey = state.uri.queryParameters['i'];
          final billboardNo = state.uri.queryParameters['billboardNo'];
          final session = BillboardFormSession(
            mode: mode,
            localDraftId: localId,
            instanceKey: instanceKey,
            billboardNo: billboardNo,
          );
          return BillboardFormPage(session: session);
        },
      ),
      GoRoute(path: AppRoutes.billboardDrafts, builder: (context, state) => const BillboardDraftsPage()),
      GoRoute(
        path: AppRoutes.investigationList,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] == 'history'
              ? InvestigationListMode.history
              : InvestigationListMode.search;
          return InvestigationListPage(module: homeModulesById['investigation']!, mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.investigationForm,
        builder: (context, state) {
          final mode = InvestigationFormModeX.fromQuery(state.uri.queryParameters['mode']);
          final instanceKey = state.uri.queryParameters['i'];
          final investigationNo = state.uri.queryParameters['investigationNo'] ?? '';
          final session = InvestigationFormSession(
            mode: mode,
            instanceKey: instanceKey,
            investigationNo: investigationNo,
          );
          return InvestigationFormPage(session: session);
        },
      ),
      GoRoute(path: AppRoutes.investigationDrafts, builder: (context, state) => const InvestigationDraftsPage()),
      GoRoute(
        path: '/module/:moduleId',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId'];
          final module = homeModulesById[moduleId] ?? homeModules.first;
          // Premise Census is the only module built so far — everything
          // else gets the shared "coming soon" placeholder.
          return switch (moduleId) {
            'premise' => PremiseListPage(module: module),
            _ => ModulePlaceholderPage(module: module),
          };
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

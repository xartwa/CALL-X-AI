import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/cubit/login_cubit.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../services/preferences_service.dart';
import '../../features/calls/calls_page.dart';
import '../../features/customers/customers_page.dart';
import '../../features/customers/customer_detail_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/email_follow_ups/email_follow_ups_page.dart';

import '../../features/ai_settings/ai_settings_page.dart';
import '../widgets/app_menu.dart';
import 'app_routes_path.dart';

class AppRouter {
  AppRouter(this._preferencesService);

  final PreferencesService _preferencesService;

  late final GoRouter router = GoRouter(
    initialLocation: _preferencesService.getAccessToken() != null
        ? AppRoutesPath.dashboard
        : AppRoutesPath.login,
    routes: [
      GoRoute(
        path: AppRoutesPath.login,
        name: AppRoutesPath.loginName,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProvider(
            create: (context) => LoginCubit(
              authRepository: context.read<AuthRepository>(),
              preferencesService: context.read<PreferencesService>(),
            ),
            child: const LoginPage(),
          ),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppMenu(child: child),
        routes: [
          //!‌ DASHBOARD
          GoRoute(
            path: AppRoutesPath.dashboard,
            name: AppRoutesPath.dashboardName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),

          //! CUSTOMERS
          GoRoute(
            path: AppRoutesPath.customers,
            name: AppRoutesPath.customersName,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const CustomersPage(),
            ),
            routes: [
              GoRoute(
                path: AppRoutesPath.customerDetail,
                name: AppRoutesPath.customerDetailName,
                pageBuilder: (context, state) {
                  final idStr = state.pathParameters['id'] ?? '0';
                  return NoTransitionPage(
                    child: CustomerDetailPage(customerId: idStr),
                  );
                },
              ),
            ],
          ),

          //! CALLS
          GoRoute(
            path: AppRoutesPath.calls,
            name: AppRoutesPath.callsName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CallsPage(),
            ),
          ),

          //! EMAIL - FOLLOW - UPS
          GoRoute(
            path: AppRoutesPath.emailFollowUps,
            name: AppRoutesPath.emailFollowUpsName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmailFollowUpsPage(),
            ),
          ),

          //! QUESTION BANK
          GoRoute(
            path: AppRoutesPath.aiSettings,
            name: AppRoutesPath.aiSettingsName,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiSettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callx_ai/app.dart';
import 'package:callx_ai/theme/theme_cubit.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/core/constants/app_constants.dart';
import 'package:callx_ai/core/routes/routes.dart';
import 'package:callx_ai/features/auth/repository/auth_repository.dart';
import 'package:callx_ai/services/api_provider.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:callx_ai/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:callx_ai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:callx_ai/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:callx_ai/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';

import 'package:callx_ai/core/datasources/workspace_remote_data_source.dart';
import 'package:callx_ai/core/repositories/workspace_repository.dart';
import 'package:callx_ai/core/repositories/workspace_repository_impl.dart';
import 'package:callx_ai/features/calls/data/datasources/calls_remote_data_source.dart';
import 'package:callx_ai/features/calls/data/repositories/calls_repository_impl.dart';
import 'package:callx_ai/features/calls/domain/repositories/calls_repository.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/email_follow_ups/cubit/email_follow_ups_cubit.dart';
import 'package:callx_ai/features/email_follow_ups/data/email_remote_data_source.dart';
import 'package:callx_ai/features/email_follow_ups/data/email_repository_impl.dart';
import 'package:callx_ai/features/email_follow_ups/domain/email_repository.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/data/datasources/ai_settings_remote_data_source.dart';
import 'package:callx_ai/features/ai_settings/data/repositories/ai_settings_repository_impl.dart';
import 'package:callx_ai/features/ai_settings/domain/repositories/ai_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(sharedPreferences);
  final dioClient = DioClient(
    baseUrl: AppConstants.apiBaseUrl,
    accessTokenProvider: preferencesService.getAccessToken,
  );
  final authRepository = AuthRepository(dioClient);
  final dashboardRepository = DashboardRepositoryImpl(
    DashboardRemoteDataSource(dioClient),
  );
  final customerRepository = CustomerRepositoryImpl(
    CustomerRemoteDataSource(dioClient),
  );
  final workspaceRepository = WorkspaceRepositoryImpl(
    WorkspaceRemoteDataSource(dioClient),
  );
  final callsRepository = CallsRepositoryImpl(
    CallsRemoteDataSource(dioClient),
  );
  final emailRepository = EmailRepositoryImpl(
    EmailRemoteDataSource(dioClient),
  );
  final aiSettingsRepository = AiSettingsRepositoryImpl(
    AiSettingsRemoteDataSource(dioClient),
  );
  final appRouter = AppRouter(preferencesService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: preferencesService),
        RepositoryProvider.value(value: dioClient),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider<DashboardRepository>.value(
            value: dashboardRepository),
        RepositoryProvider<CustomerRepository>.value(value: customerRepository),
        RepositoryProvider<WorkspaceRepository>.value(
            value: workspaceRepository),
        RepositoryProvider<CallsRepository>.value(value: callsRepository),
        RepositoryProvider<EmailRepository>.value(value: emailRepository),
        RepositoryProvider<AiSettingsRepository>.value(
          value: aiSettingsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(preferencesService)),
          BlocProvider(
            create: (context) => CustomersCubit(
              context.read<CustomerRepository>(),
            )..loadInitial(resetFilters: true),
          ),
          BlocProvider(
            create: (context) => CallsCubit(
              context.read<CallsRepository>(),
            )..loadInitial(),
          ),
          BlocProvider(create: (_) => SelectedCallCubit()),
          BlocProvider(
            create: (_) => EmailFollowUpsCubit(emailRepository),
          ),
          BlocProvider(
            create: (_) => AiSettingsCubit(aiSettingsRepository)..load(),
          ),
          BlocProvider(
            create: (_) => WorkspaceSettingsCubit(
              workspaceRepository: workspaceRepository,
              preferencesService: preferencesService,
            )..loadConfiguration(),
          ),
        ],
        child: CallCenterApp(router: appRouter.router),
      ),
    ),
  );
}

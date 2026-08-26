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
  final appRouter = AppRouter(preferencesService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: preferencesService),
        RepositoryProvider.value(value: dioClient),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider<DashboardRepository>.value(
            value: dashboardRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(preferencesService)),
          BlocProvider(create: (_) => CustomersCubit(preferencesService)),
          BlocProvider(
              create: (_) => WorkspaceSettingsCubit(
                  preferencesService: preferencesService)),
        ],
        child: CallCenterApp(router: appRouter.router),
      ),
    ),
  );
}

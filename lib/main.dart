import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callx_ai/app.dart';
import 'package:callx_ai/theme/theme_cubit.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/core/constants/app_constants.dart';
import 'package:callx_ai/core/routes/routes.dart';
import 'package:callx_ai/services/api_provider.dart';
import 'package:callx_ai/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(sharedPreferences);
  final dioClient = DioClient(baseUrl: AppConstants.apiBaseUrl);
  final appRouter = AppRouter(preferencesService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: preferencesService),
        RepositoryProvider.value(value: dioClient),
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

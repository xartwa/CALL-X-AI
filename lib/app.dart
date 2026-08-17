import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:callx_ai/theme/theme_cubit.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/theme/app_theme.dart';

class CallCenterApp extends StatelessWidget {
  const CallCenterApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final strings = AppStrings.current;
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: strings.appTitle,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          routerConfig: router,
          locale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'),
          ],
        );
      },
    );
  }
}

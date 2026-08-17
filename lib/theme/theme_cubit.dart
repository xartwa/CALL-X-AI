import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._preferencesService)
      : super(_preferencesService.loadThemeMode());

  final PreferencesService _preferencesService;

  Future<void> setTheme(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _preferencesService.saveThemeMode(mode);
  }

  Future<void> cycleTheme() {
    final nextMode = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    return setTheme(nextMode);
  }
}

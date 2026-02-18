import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'settings_store.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  return SettingsStore(ref.watch(sharedPreferencesProvider));
});

final apiBaseUrlFromEnvProvider = Provider<String>((ref) {
  return const String.fromEnvironment('API_BASE_URL', defaultValue: '');
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController({
    required SettingsStore store,
    required String apiBaseUrlFromEnv,
  })  : _store = store,
        super(store.load(apiBaseUrlFromEnv: apiBaseUrlFromEnv));

  final SettingsStore _store;

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _store.setThemeMode(mode);
  }

  Future<void> setApiBaseUrl(String url) async {
    state = state.copyWith(apiBaseUrl: url);
    await _store.setApiBaseUrl(url);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _store.setLocale(locale);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(
    store: ref.watch(settingsStoreProvider),
    apiBaseUrlFromEnv: ref.watch(apiBaseUrlFromEnvProvider),
  );
});

ThemeMode toMaterialThemeMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}



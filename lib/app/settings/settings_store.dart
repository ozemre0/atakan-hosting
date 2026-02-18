import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class SettingsStore {
  SettingsStore(this._prefs);

  static const _kThemeMode = 'theme_mode';
  static const _kApiBaseUrl = 'api_base_url';
  static const _kLocale = 'locale';

  final SharedPreferences _prefs;

  AppSettings load({
    required String apiBaseUrlFromEnv,
  }) {
    final themeRaw = _prefs.getString(_kThemeMode) ?? AppThemeMode.system.name;
    final theme = AppThemeMode.values.firstWhere(
      (e) => e.name == themeRaw,
      orElse: () => AppThemeMode.system,
    );

    final storedBaseUrl = _prefs.getString(_kApiBaseUrl) ?? '';
    final apiBaseUrl = storedBaseUrl.isNotEmpty ? storedBaseUrl : apiBaseUrlFromEnv;

    final locale = _prefs.getString(_kLocale) ?? 'tr'; // Default to Turkish

    return AppSettings(
      apiBaseUrl: apiBaseUrl,
      themeMode: theme,
      locale: locale,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_kThemeMode, mode.name);
  }

  Future<void> setApiBaseUrl(String url) async {
    await _prefs.setString(_kApiBaseUrl, url);
  }

  Future<void> setLocale(String locale) async {
    await _prefs.setString(_kLocale, locale);
  }
}



enum AppThemeMode {
  system,
  light,
  dark,
}

class AppSettings {
  const AppSettings({
    required this.apiBaseUrl,
    required this.themeMode,
    required this.locale,
  });

  final String apiBaseUrl;
  final AppThemeMode themeMode;
  final String locale; // 'tr' or 'en'

  AppSettings copyWith({
    String? apiBaseUrl,
    AppThemeMode? themeMode,
    String? locale,
  }) {
    return AppSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}



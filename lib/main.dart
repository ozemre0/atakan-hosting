import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/auth/auth_providers.dart';
import 'app/l10n/l10n_ext.dart';
import 'app/router/app_router.dart';
import 'app/settings/settings_providers.dart';
import 'app/theme/app_theme.dart';
import 'package:atakan/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AppBootstrap(),
    ),
  );
}

class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final router = buildRouter(
      apiBaseUrl: settings.apiBaseUrl,
      isLoggedIn: auth.isLoggedIn,
    );

    // Parse locale from settings
    final locale = Locale(settings.locale);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      routerConfig: router,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: toMaterialThemeMode(settings.themeMode),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
          ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

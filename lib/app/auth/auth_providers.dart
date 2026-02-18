import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../settings/settings_providers.dart';
import 'auth_state.dart';
import 'auth_store.dart';

final authStoreProvider = Provider<AuthStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthStore(prefs);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthStore store,
  })  : _store = store,
        super(AuthState(token: store.loadToken()));

  final AuthStore _store;

  Future<void> setToken(String token) async {
    state = state.copyWith(token: token);
    await _store.saveToken(token);
  }

  Future<void> clear() async {
    state = state.copyWith(token: '');
    await _store.clearToken();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(store: ref.watch(authStoreProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = ref.watch(settingsControllerProvider).apiBaseUrl;
  final token = ref.watch(authControllerProvider).token;
  final tokenAtBuild = token;
  return ApiClient(
    baseUrl: baseUrl,
    token: tokenAtBuild.isEmpty ? null : tokenAtBuild,
    onUnauthorized: () async {
      // Race-safe: only clear if the token used for this client is still current.
      final tokenNow = ref.read(authControllerProvider).token;
      if (tokenAtBuild.isNotEmpty && tokenNow == tokenAtBuild) {
        await ref.read(authControllerProvider.notifier).clear();
      }
    },
  );
});



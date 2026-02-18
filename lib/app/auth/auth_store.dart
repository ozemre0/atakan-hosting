import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  AuthStore(this._prefs);

  static const _kToken = 'admin_token';

  final SharedPreferences _prefs;

  String loadToken() => _prefs.getString(_kToken) ?? '';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_kToken, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_kToken);
  }
}



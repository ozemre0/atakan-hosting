class AuthState {
  const AuthState({
    required this.token,
  });

  final String token;

  bool get isLoggedIn => token.isNotEmpty;

  AuthState copyWith({
    String? token,
  }) {
    return AuthState(
      token: token ?? this.token,
    );
  }
}



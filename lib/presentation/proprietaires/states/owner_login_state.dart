// Fichier : lib/presentation/proprietaires/states/owner_login_state.dart

enum LoginStatus { initial, loading, success, failure }

class OwnerLoginState {
  final LoginStatus status;
  final String? errorMessage;
  final String? authToken; // Le jeton JWT en cas de succès

  OwnerLoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.authToken,
  });

  OwnerLoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? authToken,
  }) {
    return OwnerLoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      authToken: authToken ?? this.authToken,
    );
  }
}

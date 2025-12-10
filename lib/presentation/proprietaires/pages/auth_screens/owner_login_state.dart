enum AuthStatus { initial, loading, success, failure }

class OwnerLoginState {
  final String? email;
  final String? password;
  final bool isLoading;
  final String? errorMessage;
  final AuthStatus status;

  OwnerLoginState({
    this.email,
    this.password,
    this.isLoading = false,
    this.errorMessage,
    this.status = AuthStatus.initial,
  });

  OwnerLoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    AuthStatus? status,
  }) {
    return OwnerLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}

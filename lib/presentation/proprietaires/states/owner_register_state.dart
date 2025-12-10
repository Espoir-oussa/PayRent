// Fichier : lib/presentation/proprietaires/states/owner_register_state.dart

enum RegisterStatus { initial, loading, success, failure }

class OwnerRegisterState {
  final RegisterStatus status;
  final String? errorMessage;
  final String? authToken;

  OwnerRegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.authToken,
  });

  OwnerRegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    String? authToken,
  }) {
    return OwnerRegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      authToken: authToken ?? this.authToken,
    );
  }
}

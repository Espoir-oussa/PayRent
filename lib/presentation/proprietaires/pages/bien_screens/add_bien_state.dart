// Fichier : lib/presentation/proprietaires/pages/bien_screens/add_bien_state.dart

/// État pour la création d'un bien
enum AddBienStatus {
  initial,
  loading,
  success,
  failure,
}

/// Modèle d'état pour l'ajout de bien
class AddBienState {
  final AddBienStatus status;
  final String? errorMessage;

  const AddBienState({
    this.status = AddBienStatus.initial,
    this.errorMessage,
  });

  AddBienState copyWith({
    AddBienStatus? status,
    String? errorMessage,
  }) {
    return AddBienState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

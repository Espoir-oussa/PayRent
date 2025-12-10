// Fichier : lib/presentation/proprietaires/pages/bien_screens/edit_bien_state.dart

/// État pour la modification d'un bien
enum EditBienStatus {
  initial,
  loading,
  success,
  failure,
}

/// Modèle d'état pour la modification de bien
class EditBienState {
  final EditBienStatus status;
  final String? errorMessage;

  const EditBienState({
    this.status = EditBienStatus.initial,
    this.errorMessage,
  });

  EditBienState copyWith({
    EditBienStatus? status,
    String? errorMessage,
  }) {
    return EditBienState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

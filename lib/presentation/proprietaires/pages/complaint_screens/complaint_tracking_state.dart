// ===============================
// 📦 State : État de la gestion des plaintes
//
// Ce fichier définit les différents états possibles lors de la gestion des plaintes.
//
// Dossier : lib/presentation/proprietaires/pages/complaint_screens/
// Rôle : State management
// Utilisé par : ComplaintTrackingController
// ===============================

import '../../../../data/models/plainte_model.dart';

enum ComplaintStatus {
  initial,
  loading,
  loaded,
  error,
}

class ComplaintTrackingState {
  final ComplaintStatus status;
  final List<PlainteModel> complaints;
  final String? errorMessage;
  final bool isUpdating;

  const ComplaintTrackingState({
    this.status = ComplaintStatus.initial,
    this.complaints = const [],
    this.errorMessage,
    this.isUpdating = false,
  });

  ComplaintTrackingState copyWith({
    ComplaintStatus? status,
    List<PlainteModel>? complaints,
    String? errorMessage,
    bool? isUpdating,
  }) {
    return ComplaintTrackingState(
      status: status ?? this.status,
      complaints: complaints ?? this.complaints,
      errorMessage: errorMessage ?? this.errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

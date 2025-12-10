// ===============================
// 🎮 Controller : Gestion des plaintes
//
// Ce fichier implémente le contrôleur pour gérer les plaintes du propriétaire.
//
// Dossier : lib/presentation/proprietaires/pages/complaint_screens/
// Rôle : Controller (StateNotifier)
// Utilisé par : ComplaintTrackingScreen
// ===============================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/plaintes/get_owner_complaints_usecase.dart';
import '../../../../domain/usecases/plaintes/update_complaint_status_usecase.dart';
import 'complaint_tracking_state.dart';

class ComplaintTrackingController
    extends StateNotifier<ComplaintTrackingState> {
  final GetOwnerComplaintsUseCase getComplaintsUseCase;
  final UpdateComplaintStatusUseCase updateStatusUseCase;

  ComplaintTrackingController({
    required this.getComplaintsUseCase,
    required this.updateStatusUseCase,
  }) : super(const ComplaintTrackingState());

  // Charger les plaintes d'un propriétaire
  Future<void> loadComplaints(int ownerId) async {
    state = state.copyWith(status: ComplaintStatus.loading);

    try {
      final complaints = await getComplaintsUseCase(ownerId);
      state = state.copyWith(
        status: ComplaintStatus.loaded,
        complaints: complaints,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ComplaintStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Mettre à jour le statut d'une plainte
  Future<void> updateComplaintStatus({
    required int plainteId,
    required String newStatus,
    required int ownerId,
  }) async {
    state = state.copyWith(isUpdating: true);

    try {
      await updateStatusUseCase(
        plainteId: plainteId,
        newStatus: newStatus,
      );

      // Met à jour localement la plainte pour retour immédiat
      final updatedComplaints = state.complaints
          .map((c) => c.idPlainte == plainteId
              ? c.copyWith(statutPlainte: newStatus)
              : c)
          .toList();

      state = state.copyWith(
        isUpdating: false,
        complaints: updatedComplaints,
        status: ComplaintStatus.loaded,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Rafraîchir la liste des plaintes
  Future<void> refreshComplaints(int ownerId) async {
    await loadComplaints(ownerId);
  }
}

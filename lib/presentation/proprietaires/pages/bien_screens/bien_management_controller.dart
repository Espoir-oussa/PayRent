// Fichier : lib/presentation/proprietaires/pages/bien_screens/bien_management_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/biens/get_bien_list_usecase.dart';
import 'bien_list_state.dart';

/// Controller pour la gestion de la liste des biens
///
/// Responsabilité : Orchestrer les appels aux Use Cases et mettre à jour l'état
/// Pattern : StateNotifier de Riverpod
class BienManagementController extends StateNotifier<BienListState> {
  final GetBienListUseCase getBienListUseCase;

  BienManagementController({required this.getBienListUseCase})
      : super(const BienListState());

  /// Charge la liste des biens du propriétaire
  ///
  /// Paramètre: idProprietaire - L'ID du propriétaire
  Future<void> loadBiens(int idProprietaire) async {
    // 1. Début du chargement
    state = state.copyWith(status: BienStatus.loading, errorMessage: null);

    try {
      // 2. Exécution du Use Case
      final biens = await getBienListUseCase(idProprietaire);

      // 3. Succès
      state = state.copyWith(
        status: BienStatus.success,
        biens: biens,
      );
    } catch (e) {
      // 4. Échec
      state = state.copyWith(
        status: BienStatus.failure,
        errorMessage: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Réinitialise l'état
  void resetState() {
    state = const BienListState();
  }
}

// Fichier : lib/presentation/proprietaires/pages/bien_screens/edit_bien_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/usecases/biens/update_bien_usecase.dart';
import '../../../../core/di/providers.dart';
import 'edit_bien_state.dart';

/// Controller pour la modification de bien
class EditBienController extends StateNotifier<EditBienState> {
  final UpdateBienUseCase updateBienUseCase;

  EditBienController({
    required this.updateBienUseCase,
  }) : super(const EditBienState());

  /// Modifier un bien existant
  Future<void> updateBien({
    required int idBien,
    required int idProprietaire,
    required String adresseComplete,
    required double loyerDeBase,
    String? typeBien,
    double chargesLocatives = 0.0,
  }) async {
    // Passer en mode chargement
    state = state.copyWith(status: EditBienStatus.loading);

    try {
      // Appeler le Use Case
      await updateBienUseCase.call(
        idBien: idBien,
        idProprietaire: idProprietaire,
        adresseComplete: adresseComplete,
        loyerDeBase: loyerDeBase,
        typeBien: typeBien,
        chargesLocatives: chargesLocatives,
      );

      // Succès
      state = state.copyWith(status: EditBienStatus.success);
    } catch (e) {
      // Erreur
      state = state.copyWith(
        status: EditBienStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = const EditBienState();
  }
}

/// Provider du controller EditBien
final editBienControllerProvider =
    StateNotifierProvider.autoDispose<EditBienController, EditBienState>((ref) {
  return EditBienController(
    updateBienUseCase: ref.watch(updateBienUseCaseProvider),
  );
});

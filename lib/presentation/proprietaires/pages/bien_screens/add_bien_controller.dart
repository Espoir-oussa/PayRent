// Fichier : lib/presentation/proprietaires/pages/bien_screens/add_bien_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../domain/usecases/biens/create_bien_usecase.dart';
import 'add_bien_state.dart';

/// Controller pour la création de bien
class AddBienController extends StateNotifier<AddBienState> {
  final CreateBienUseCase createBienUseCase;

  AddBienController({
    required this.createBienUseCase,
  }) : super(const AddBienState());

  /// Créer un nouveau bien
  Future<void> createBien({
    required int idProprietaire,
    required String adresseComplete,
    required double loyerDeBase,
    String? typeBien,
    double chargesLocatives = 0.0,
  }) async {
    // Passer en mode chargement
    state = state.copyWith(status: AddBienStatus.loading);

    try {
      // Appeler le Use Case
      await createBienUseCase.call(
        idProprietaire: idProprietaire,
        adresseComplete: adresseComplete,
        loyerDeBase: loyerDeBase,
        typeBien: typeBien,
        chargesLocatives: chargesLocatives,
      );

      // Succès
      state = state.copyWith(status: AddBienStatus.success);
    } catch (e) {
      // Erreur
      state = state.copyWith(
        status: AddBienStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = const AddBienState();
  }
}

/// Provider du controller AddBien
final addBienControllerProvider =
    StateNotifierProvider.autoDispose<AddBienController, AddBienState>((ref) {
  return AddBienController(
    createBienUseCase: ref.watch(createBienUseCaseProvider),
  );
});

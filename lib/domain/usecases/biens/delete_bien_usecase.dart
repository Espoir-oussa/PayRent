// Fichier : lib/domain/usecases/biens/delete_bien_usecase.dart

import '../../repositories/bien_repository.dart';

/// Use Case : Supprimer un bien
class DeleteBienUseCase {
  final BienRepository repository;

  DeleteBienUseCase(this.repository);

  /// Supprime un bien par son ID
  ///
  /// Paramètres:
  /// - [idBien] : ID du bien à supprimer
  ///
  /// Lève une exception si l'ID est invalide
  Future<void> call({
    required int idBien,
  }) async {
    // Validation basique
    if (idBien <= 0) {
      throw Exception('L\'ID du bien doit être valide');
    }

    // Appeler le repository pour supprimer
    await repository.deleteBien(idBien);
  }
}

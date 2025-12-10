// Fichier : lib/domain/usecases/biens/update_bien_usecase.dart

import '../../entities/bien_entity.dart';
import '../../repositories/bien_repository.dart';

/// Use Case : Modifier un bien existant
class UpdateBienUseCase {
  final BienRepository repository;

  UpdateBienUseCase(this.repository);

  /// Met à jour un bien existant
  ///
  /// Paramètres:
  /// - [idBien] : ID du bien à modifier
  /// - [idProprietaire] : ID du propriétaire
  /// - [adresseComplete] : Nouvelle adresse
  /// - [loyerDeBase] : Nouveau loyer de base
  /// - [typeBien] : Type de bien (optionnel)
  /// - [chargesLocatives] : Nouvelles charges (optionnel)
  ///
  /// Retour : Le bien mis à jour
  ///
  /// Lève une exception si :
  /// - L'adresse est vide
  /// - Le loyer est inférieur ou égal à 0
  Future<BienEntity> call({
    required int idBien,
    required int idProprietaire,
    required String adresseComplete,
    required double loyerDeBase,
    String? typeBien,
    double chargesLocatives = 0.0,
  }) async {
    // Validation basique
    if (adresseComplete.isEmpty) {
      throw Exception('L\'adresse ne peut pas être vide');
    }
    if (loyerDeBase <= 0) {
      throw Exception('Le loyer doit être supérieur à 0');
    }

    // Créer l'entité mise à jour
    final bien = BienEntity(
      idBien: idBien,
      idProprietaire: idProprietaire,
      adresseComplete: adresseComplete,
      loyerDeBase: loyerDeBase,
      typeBien: typeBien,
      chargesLocatives: chargesLocatives,
    );

    return await repository.updateBien(bien);
  }
}

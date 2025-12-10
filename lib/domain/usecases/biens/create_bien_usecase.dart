// Fichier : lib/domain/usecases/biens/create_bien_usecase.dart

import '../../entities/bien_entity.dart';
import '../../repositories/bien_repository.dart';

/// Use Case : Créer un nouveau bien immobilier
class CreateBienUseCase {
  final BienRepository repository;

  CreateBienUseCase(this.repository);

  Future<BienEntity> call({
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

    // Créer l'entité
    final bien = BienEntity(
      idBien: 0, // L'API assignera l'ID
      idProprietaire: idProprietaire,
      adresseComplete: adresseComplete,
      loyerDeBase: loyerDeBase,
      typeBien: typeBien,
      chargesLocatives: chargesLocatives,
    );

    return await repository.createBien(bien);
  }
}

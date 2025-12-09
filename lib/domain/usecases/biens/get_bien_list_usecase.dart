// Fichier : lib/domain/usecases/biens/get_bien_list_usecase.dart

import '../../entities/bien_entity.dart';
import '../../repositories/bien_repository.dart';

/// Use Case : Récupérer la liste des biens d'un propriétaire
///
/// Responsabilité : Encapsuler la logique métier pour obtenir les biens
///
/// Pattern : Chaque Use Case a une seule responsabilité (Single Responsibility Principle)
/// Utilisé par : Présentation (Controllers/Screens)
class GetBienListUseCase {
  final BienRepository repository;

  GetBienListUseCase(this.repository);

  /// Exécute le Use Case
  ///
  /// Paramètre: idProprietaire - L'ID du propriétaire
  /// Retour: Futur contenant la liste des biens
  Future<List<BienEntity>> call(int idProprietaire) async {
    return await repository.getBiensByProprietaire(idProprietaire);
  }
}

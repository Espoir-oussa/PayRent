// Fichier : lib/domain/repositories/bien_repository.dart

import '../entities/bien_entity.dart';

/// Interface (contrat) pour l'accès aux données des biens immobiliers
///
/// Cette interface définit les méthodes que tout repository implémentant ce contrat
/// DOIT implémenter. Cela respecte le principe D de SOLID (Dependency Inversion).
///
/// Utilisée par : Use Cases
/// Implémentée par : BienRepositoryImpl (Data Layer)
abstract class BienRepository {
  /// Récupère la liste de tous les biens d'un propriétaire
  ///
  /// Paramètres:
  ///   - idProprietaire : L'ID du propriétaire
  ///
  /// Retour : Liste des BienEntity
  ///
  /// Lance une exception si l'appel API échoue
  Future<List<BienEntity>> getBiensByProprietaire(int idProprietaire);

  /// Récupère un bien spécifique par son ID
  Future<BienEntity> getBienById(int idBien);

  /// Crée un nouveau bien
  Future<BienEntity> createBien(BienEntity bien);

  /// Met à jour un bien existant
  Future<BienEntity> updateBien(BienEntity bien);

  /// Supprime un bien
  Future<void> deleteBien(int idBien);
}

// ===============================
// 📄 Contrat Repository : Bien
//
// Ce fichier définit l'interface (contrat) pour l'accès aux données des biens immobiliers.
//
// Dossier : lib/domain/repositories/
// Rôle : Déclaration des méthodes d'accès aux données (Clean Architecture)
// Utilisé par : Use Cases, Data Layer
// ===============================

import '../../data/models/bien_model.dart';

abstract class BienRepository {
  /// Récupérer tous les biens d'un propriétaire
  Future<List<BienModel>> getBiensByProprietaire(String proprietaireId);
  
  /// Récupérer un bien par son ID
  Future<BienModel> getBienById(String bienId);
  
  /// Créer un nouveau bien
  Future<BienModel> createBien(BienModel bien);
  
  /// Mettre à jour un bien
  Future<BienModel> updateBien(String bienId, BienModel bien);
  
  /// Supprimer un bien
  Future<void> deleteBien(String bienId);
  
  /// Rechercher des biens par critères
  Future<List<BienModel>> searchBiens({
    String? typeBien,
    double? loyerMin,
    double? loyerMax,
    String? adresse,
  });
}
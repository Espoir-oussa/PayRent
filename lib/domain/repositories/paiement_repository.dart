// ===============================
// 📄 Contrat Repository : Paiement
//
// Ce fichier définit l'interface (contrat) pour l'accès aux données des paiements.
// ===============================

import '../../data/models/paiement_model.dart';

abstract class PaiementRepository {
  /// Récupérer tous les paiements d'un contrat
  Future<List<PaiementModel>> getPaiementsByContrat(String contratId);
  
  /// Récupérer tous les paiements d'un locataire (via ses contrats)
  Future<List<PaiementModel>> getPaiementsByLocataire(String locataireId);
  
  /// Récupérer un paiement par son ID
  Future<PaiementModel> getPaiementById(String paiementId);
  
  /// Créer un nouveau paiement
  Future<PaiementModel> createPaiement(PaiementModel paiement);
  
  /// Mettre à jour le statut d'un paiement
  Future<PaiementModel> updatePaiementStatut(String paiementId, String statut);
  
  /// Récupérer les paiements par statut
  Future<List<PaiementModel>> getPaiementsByStatut(String statut);
  
  /// Récupérer les paiements pour un mois donné
  Future<List<PaiementModel>> getPaiementsByMois(String moisConcerne);
  
  /// Vérifier si un paiement existe pour un mois et un contrat
  Future<bool> paiementExistePourMois(String contratId, String moisConcerne);
}

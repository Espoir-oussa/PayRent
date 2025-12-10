// ===============================
// 📄 Contrat Repository : Contrat de Location
//
// Ce fichier définit l'interface (contrat) pour l'accès aux données des contrats.
// ===============================

import '../../data/models/contrat_location_model.dart';

abstract class ContratRepository {
  /// Récupérer tous les contrats d'un propriétaire
  Future<List<ContratLocationModel>> getContratsByProprietaire(String proprietaireId);
  
  /// Récupérer tous les contrats d'un locataire
  Future<List<ContratLocationModel>> getContratsByLocataire(String locataireId);
  
  /// Récupérer les contrats d'un bien
  Future<List<ContratLocationModel>> getContratsByBien(String bienId);
  
  /// Récupérer un contrat par son ID
  Future<ContratLocationModel> getContratById(String contratId);
  
  /// Créer un nouveau contrat
  Future<ContratLocationModel> createContrat(ContratLocationModel contrat);
  
  /// Mettre à jour un contrat
  Future<ContratLocationModel> updateContrat(String contratId, ContratLocationModel contrat);
  
  /// Résilier un contrat
  Future<void> resilierContrat(String contratId);
  
  /// Récupérer le contrat actif d'un locataire
  Future<ContratLocationModel?> getContratActifByLocataire(String locataireId);
}

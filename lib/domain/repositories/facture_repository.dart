// ===============================
// 📄 Contrat Repository : Facture
//
// Ce fichier définit l'interface (contrat) pour l'accès aux données des factures.
// ===============================

import '../../data/models/facture_model.dart';

abstract class FactureRepository {
  /// Récupérer toutes les factures d'un paiement
  Future<FactureModel?> getFactureByPaiement(String paiementId);
  
  /// Récupérer une facture par son ID
  Future<FactureModel> getFactureById(String factureId);
  
  /// Récupérer toutes les factures d'un locataire
  Future<List<FactureModel>> getFacturesByLocataire(String locataireId);
  
  /// Créer une nouvelle facture
  Future<FactureModel> createFacture(FactureModel facture);
  
  /// Récupérer les factures par période
  Future<List<FactureModel>> getFacturesByPeriode(DateTime debut, DateTime fin);
  
  /// Télécharger le PDF d'une facture
  Future<String> getFacturePdfUrl(String factureId);
}

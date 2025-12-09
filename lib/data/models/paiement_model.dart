
// ===============================
// 💸 Modèle de Donnée : Paiement
//
// Ce fichier définit la structure du modèle "Paiement"
// pour la couche Data de l'application PayRent.
//
// Sert à la conversion des données reçues de l'API (ou de la base de données)
// en objets Dart utilisables dans l'application.
//
// Dossier : lib/data/models/
// Rôle : Modèle de données (Data Model)
// Utilisé par : Repositories, Use Cases, Présentation
// ===============================

// TODO: Définir la classe PaiementModel selon le MLD
// Exemple de structure possible :
// class PaiementModel {
//   final String id;
//   final double montant;
//   final DateTime datePaiement;
//   final String locataireId;
//   // ... autres champs
// }


// Fichier : lib/data/models/paiement_model.dart

class PaiementModel {
  final int idPaiement;
  final int idContrat; // FK vers CONTRAT_LOCATION [cite: 30, 72]
  final double montantPaye; // DECIMAL (10, 2) [cite: 69]
  final DateTime datePaiement;
  final String statut; // 'Réussi', 'Echoué', 'En Attente' [cite: 71]
  final String? referenceTransactionFedapay; // UNIQUE, NULLABLE [cite: 30, 71]

  PaiementModel({
    required this.idPaiement,
    required this.idContrat,
    required this.montantPaye,
    required this.datePaiement,
    required this.statut,
    this.referenceTransactionFedapay,
  });

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    return PaiementModel(
      idPaiement: json['id_paiement'],
      idContrat: json['id_contrat'],
      montantPaye: (json['montant_paye'] as num).toDouble(),
      datePaiement: DateTime.parse(json['date_paiement']),
      statut: json['statut'],
      referenceTransactionFedapay: json['reference_transaction_fedapay'],
    );
  }

  // Utilisé par le Locataire pour créer une demande de paiement vers Fedapay
  Map<String, dynamic> toJson() {
    return {
      'id_contrat': idContrat,
      'montant_paye': montantPaye,
      // La date_paiement et le statut sont généralement fixés par le Backend après la transaction
    };
  }
}
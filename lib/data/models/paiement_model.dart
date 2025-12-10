// ===============================
// 💸 Modèle de Donnée : Paiement
//
// Ce fichier définit la structure du modèle "Paiement"
// pour la couche Data de l'application PayRent.
// ===============================

import 'package:appwrite/models.dart' as models;

class PaiementModel {
  final String? appwriteId; // ID Appwrite du document
  final int idPaiement;
  final String idContrat; // ID Appwrite du contrat
  final double montantPaye;
  final DateTime datePaiement;
  final String statut; // 'Réussi', 'Echoué', 'En Attente'
  final String? referenceTransactionFedapay;
  final String? methodePaiement; // 'mobile_money', 'carte', 'especes'
  final String? moisConcerne; // Format: '2024-01' pour janvier 2024
  final DateTime? dateCreation;

  PaiementModel({
    this.appwriteId,
    required this.idPaiement,
    required this.idContrat,
    required this.montantPaye,
    required this.datePaiement,
    required this.statut,
    this.referenceTransactionFedapay,
    this.methodePaiement,
    this.moisConcerne,
    this.dateCreation,
  });

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    return PaiementModel(
      idPaiement: json['id_paiement'],
      idContrat: json['id_contrat'].toString(),
      montantPaye: (json['montant_paye'] as num).toDouble(),
      datePaiement: DateTime.parse(json['date_paiement']),
      statut: json['statut'],
      referenceTransactionFedapay: json['reference_transaction_fedapay'],
      methodePaiement: json['methode_paiement'],
      moisConcerne: json['mois_concerne'],
    );
  }

  /// Factory pour créer depuis un document Appwrite
  factory PaiementModel.fromAppwrite(models.Document doc) {
    final data = doc.data;
    return PaiementModel(
      appwriteId: doc.$id,
      idPaiement: 0,
      idContrat: data['id_contrat'] ?? '',
      montantPaye: (data['montant_paye'] as num?)?.toDouble() ?? 0.0,
      datePaiement: DateTime.parse(data['date_paiement']),
      statut: data['statut'] ?? 'En Attente',
      referenceTransactionFedapay: data['reference_transaction_fedapay'],
      methodePaiement: data['methode_paiement'],
      moisConcerne: data['mois_concerne'],
      dateCreation: data['date_creation'] != null
          ? DateTime.parse(data['date_creation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_contrat': idContrat,
      'montant_paye': montantPaye,
      'statut': statut,
      'reference_transaction_fedapay': referenceTransactionFedapay,
      'methode_paiement': methodePaiement,
      'mois_concerne': moisConcerne,
    };
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'id_contrat': idContrat,
      'montant_paye': montantPaye,
      'date_paiement': datePaiement.toIso8601String(),
      'statut': statut,
      'reference_transaction_fedapay': referenceTransactionFedapay,
      'methode_paiement': methodePaiement,
      'mois_concerne': moisConcerne,
      'date_creation': dateCreation?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  PaiementModel copyWith({
    String? appwriteId,
    int? idPaiement,
    String? idContrat,
    double? montantPaye,
    DateTime? datePaiement,
    String? statut,
    String? referenceTransactionFedapay,
    String? methodePaiement,
    String? moisConcerne,
    DateTime? dateCreation,
  }) {
    return PaiementModel(
      appwriteId: appwriteId ?? this.appwriteId,
      idPaiement: idPaiement ?? this.idPaiement,
      idContrat: idContrat ?? this.idContrat,
      montantPaye: montantPaye ?? this.montantPaye,
      datePaiement: datePaiement ?? this.datePaiement,
      statut: statut ?? this.statut,
      referenceTransactionFedapay: referenceTransactionFedapay ?? this.referenceTransactionFedapay,
      methodePaiement: methodePaiement ?? this.methodePaiement,
      moisConcerne: moisConcerne ?? this.moisConcerne,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
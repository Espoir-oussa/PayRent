// ===============================
// 🧾 Modèle de Donnée : Facture
//
// Ce fichier définit la structure du modèle "Facture"
// pour la couche Data de l'application PayRent.
// ===============================

import 'package:appwrite/models.dart' as models;

class FactureModel {
  final String? appwriteId; // ID Appwrite du document
  final int idFacture;
  final String idPaiement; // ID Appwrite du paiement associé
  final DateTime dateEmission;
  final String? cheminFichierPdf; // ID du fichier dans le bucket
  final String? numeroFacture; // Numéro de facture formaté
  final double montant;
  final String? description;

  FactureModel({
    this.appwriteId,
    required this.idFacture,
    required this.idPaiement,
    required this.dateEmission,
    this.cheminFichierPdf,
    this.numeroFacture,
    this.montant = 0.0,
    this.description,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) {
    return FactureModel(
      idFacture: json['id_facture'],
      idPaiement: json['id_paiement'].toString(),
      dateEmission: DateTime.parse(json['date_emission']),
      cheminFichierPdf: json['chemin_fichier_pdf'],
      numeroFacture: json['numero_facture'],
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
    );
  }

  /// Factory pour créer depuis un document Appwrite
  factory FactureModel.fromAppwrite(models.Document doc) {
    final data = doc.data;
    return FactureModel(
      appwriteId: doc.$id,
      idFacture: 0,
      idPaiement: data['id_paiement'] ?? '',
      dateEmission: DateTime.parse(data['date_emission']),
      cheminFichierPdf: data['chemin_fichier_pdf'],
      numeroFacture: data['numero_facture'],
      montant: (data['montant'] as num?)?.toDouble() ?? 0.0,
      description: data['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_paiement': idPaiement,
      'date_emission': dateEmission.toIso8601String(),
      'chemin_fichier_pdf': cheminFichierPdf,
      'numero_facture': numeroFacture,
      'montant': montant,
      'description': description,
    };
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'id_paiement': idPaiement,
      'date_emission': dateEmission.toIso8601String(),
      'chemin_fichier_pdf': cheminFichierPdf,
      'numero_facture': numeroFacture,
      'montant': montant,
      'description': description,
    };
  }

  FactureModel copyWith({
    String? appwriteId,
    int? idFacture,
    String? idPaiement,
    DateTime? dateEmission,
    String? cheminFichierPdf,
    String? numeroFacture,
    double? montant,
    String? description,
  }) {
    return FactureModel(
      appwriteId: appwriteId ?? this.appwriteId,
      idFacture: idFacture ?? this.idFacture,
      idPaiement: idPaiement ?? this.idPaiement,
      dateEmission: dateEmission ?? this.dateEmission,
      cheminFichierPdf: cheminFichierPdf ?? this.cheminFichierPdf,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      montant: montant ?? this.montant,
      description: description ?? this.description,
    );
  }
}
// ===============================
// 📦 Modèle de Donnée : Bien
//
// Ce fichier définit la structure du modèle "Bien" (propriété immobilière)
// pour la couche Data de l'application PayRent.
//
// Il sert à la conversion des données reçues de l'API (ou de la base de données)
// en objets Dart utilisables dans l'application.
//
// Dossier : lib/data/models/
// Rôle : Modèle de données (Data Model)
// Utilisé par : Repositories, Use Cases, Présentation
// ===============================

// TODO: Définir la classe BienModel selon le MLD (Modèle Logique de Données)
// Exemple de structure possible :
// class BienModel {
//   final String id;
//   final String nom;
//   final String adresse;
//   final String type;
//   final int nombrePieces;
//   // ... autres champs selon vos besoins
//
//   BienModel({
//     required this.id,
//     required this.nom,
//     required this.adresse,
//     required this.type,
//     required this.nombrePieces,
//   });
//
//   // Méthodes de sérialisation/désérialisation (fromJson, toJson)
// }

// Fichier : lib/data/models/bien_model.dart

import '../../domain/entities/bien_entity.dart';

class BienModel extends BienEntity {
  BienModel({
    required int idBien,
    required int idProprietaire,
    required String adresseComplete,
    required double loyerDeBase,
    String? typeBien,
    double chargesLocatives = 0.0,
  }) : super(
          idBien: idBien,
          idProprietaire: idProprietaire,
          adresseComplete: adresseComplete,
          loyerDeBase: loyerDeBase,
          typeBien: typeBien,
          chargesLocatives: chargesLocatives,
        );

  factory BienModel.fromJson(Map<String, dynamic> json) {
    return BienModel(
      idBien: json['id_bien'],
      idProprietaire: json['id_proprietaire'],
      adresseComplete: json['adresse_complete'],
      typeBien: json['type_bien'],
      // Conversion des types numériques (peut être String ou int/double en JSON)
      loyerDeBase: (json['loyer_de_base'] as num).toDouble(),
      chargesLocatives: (json['charges_locatives'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_proprietaire': idProprietaire,
      'adresse_complete': adresseComplete,
      'type_bien': typeBien,
      'loyer_de_base': loyerDeBase,
      'charges_locatives': chargesLocatives,
    };
  }
}

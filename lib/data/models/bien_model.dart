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

import 'package:appwrite/models.dart' as models;

class BienModel {
  final String? appwriteId; // ID Appwrite du document
  final int idBien;
  final String idProprietaire; // ID Appwrite du propriétaire
  final String adresseComplete;
  final String? typeBien;
  final double loyerDeBase;
  final double chargesLocatives;
  final String? imagePath; // Chemin ou URL de l'image du bien
  final DateTime? dateCreation;

  BienModel({
    this.appwriteId,
    required this.idBien,
    required this.idProprietaire,
    required this.adresseComplete,
    required this.loyerDeBase,
    this.typeBien,
    this.chargesLocatives = 0.0,
    this.imagePath,
    this.dateCreation,
  });

  factory BienModel.fromJson(Map<String, dynamic> json) {
    return BienModel(
      idBien: json['id_bien'],
      idProprietaire: json['id_proprietaire'].toString(),
      adresseComplete: json['adresse_complete'],
      typeBien: json['type_bien'],
      loyerDeBase: (json['loyer_de_base'] as num).toDouble(),
      chargesLocatives: (json['charges_locatives'] as num?)?.toDouble() ?? 0.0,
      imagePath: json['image_path'],
    );
  }

  /// Factory pour créer un BienModel depuis un document Appwrite
  factory BienModel.fromAppwrite(models.Document doc) {
    final data = doc.data;
    return BienModel(
      appwriteId: doc.$id,
      idBien: 0, // L'ID numérique n'est pas utilisé avec Appwrite
      idProprietaire: data['id_proprietaire'] ?? '',
      adresseComplete: data['adresse_complete'] ?? '',
      typeBien: data['type_bien'],
      loyerDeBase: (data['loyer_de_base'] as num?)?.toDouble() ?? 0.0,
      chargesLocatives: (data['charges_locatives'] as num?)?.toDouble() ?? 0.0,
      imagePath: data['image_path'],
      dateCreation: data['date_creation'] != null 
          ? DateTime.parse(data['date_creation']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_proprietaire': idProprietaire,
      'adresse_complete': adresseComplete,
      'type_bien': typeBien,
      'loyer_de_base': loyerDeBase,
      'charges_locatives': chargesLocatives,
      'image_path': imagePath,
    };
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'id_proprietaire': idProprietaire,
      'adresse_complete': adresseComplete,
      'type_bien': typeBien,
      'loyer_de_base': loyerDeBase,
      'charges_locatives': chargesLocatives,
      'image_path': imagePath,
      'date_creation': dateCreation?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Créer une copie avec des modifications
  BienModel copyWith({
    String? appwriteId,
    int? idBien,
    String? idProprietaire,
    String? adresseComplete,
    String? typeBien,
    double? loyerDeBase,
    double? chargesLocatives,
    String? imagePath,
    DateTime? dateCreation,
  }) {
    return BienModel(
      appwriteId: appwriteId ?? this.appwriteId,
      idBien: idBien ?? this.idBien,
      idProprietaire: idProprietaire ?? this.idProprietaire,
      adresseComplete: adresseComplete ?? this.adresseComplete,
      typeBien: typeBien ?? this.typeBien,
      loyerDeBase: loyerDeBase ?? this.loyerDeBase,
      chargesLocatives: chargesLocatives ?? this.chargesLocatives,
      imagePath: imagePath ?? this.imagePath,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
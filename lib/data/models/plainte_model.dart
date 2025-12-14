// ===============================
// 📝 Modèle de Donnée : Plainte
//
// Ce fichier définit la structure du modèle "Plainte"
// pour la couche Data de l'application PayRent.
// ===============================

import 'package:appwrite/models.dart' as models;

class PlainteModel {
  final String? appwriteId; // ID Appwrite du document
  final int idPlainte;
  final String idLocataire; // ID Appwrite du locataire
  final String idBien; // ID Appwrite du bien
  final String idProprietaireGestionnaire; // ID Appwrite du propriétaire
  final DateTime dateCreation;
  final String sujet;
  final String description;
  final String statutPlainte; // 'Ouverte', 'En cours', 'Résolue', 'Fermée'
  final String? reponse; // Réponse du propriétaire
  final DateTime? dateReponse;
  final List<String>? imagesIds; // IDs des images dans le bucket

  PlainteModel({
    this.appwriteId,
    required this.idPlainte,
    required this.idLocataire,
    required this.idBien,
    required this.idProprietaireGestionnaire,
    required this.dateCreation,
    required this.sujet,
    required this.description,
    required this.statutPlainte,
    this.reponse,
    this.dateReponse,
    this.imagesIds,
  });

  factory PlainteModel.fromJson(Map<String, dynamic> json) {
    return PlainteModel(
      idPlainte: json['id_plainte'],
      idLocataire: json['id_locataire'].toString(),
      idBien: json['id_bien'].toString(),
      idProprietaireGestionnaire: json['id_proprietaire_gestionnaire'].toString(),
      dateCreation: DateTime.parse(json['date_creation']),
      sujet: json['sujet'],
      description: json['description'],
      statutPlainte: json['statut_plainte'],
      reponse: json['reponse'],
      dateReponse: json['date_reponse'] != null
          ? DateTime.parse(json['date_reponse'])
          : null,
    );
  }

  /// Factory pour créer depuis un document Appwrite
  factory PlainteModel.fromAppwrite(models.Document doc) {
    final data = doc.data;
    return PlainteModel(
      appwriteId: doc.$id,
      idPlainte: 0,
      idLocataire: data['id_locataire'] ?? '',
      idBien: data['id_bien'] ?? '',
      idProprietaireGestionnaire: data['id_proprietaire_gestionnaire'] ?? '',
      dateCreation: DateTime.parse(data['date_creation']),
      sujet: data['sujet'] ?? '',
      description: data['description'] ?? '',
      statutPlainte: data['statut_plainte'] ?? 'Ouverte',
      reponse: data['reponse'],
      dateReponse: data['date_reponse'] != null
          ? DateTime.parse(data['date_reponse'])
          : null,
      imagesIds: data['images_ids'] != null
          ? List<String>.from(data['images_ids'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_locataire': idLocataire,
      'id_bien': idBien,
      'sujet': sujet,
      'description': description,
    };
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'id_locataire': idLocataire,
      'id_bien': idBien,
      'id_proprietaire_gestionnaire': idProprietaireGestionnaire,
      'date_creation': dateCreation.toIso8601String(),
      'sujet': sujet,
      'description': description,
      'statut_plainte': statutPlainte,
      'reponse': reponse,
      'date_reponse': dateReponse?.toIso8601String(),
      'images_ids': imagesIds,
    };
  }

  PlainteModel copyWith({
    String? appwriteId,
    int? idPlainte,
    String? idLocataire,
    String? idBien,
    String? idProprietaireGestionnaire,
    DateTime? dateCreation,
    String? sujet,
    String? description,
    String? statutPlainte,
    String? reponse,
    DateTime? dateReponse,
    List<String>? imagesIds,
  }) {
    return PlainteModel(
      appwriteId: appwriteId ?? this.appwriteId,
      idPlainte: idPlainte ?? this.idPlainte,
      idLocataire: idLocataire ?? this.idLocataire,
      idBien: idBien ?? this.idBien,
      idProprietaireGestionnaire: idProprietaireGestionnaire ?? this.idProprietaireGestionnaire,
      dateCreation: dateCreation ?? this.dateCreation,
      sujet: sujet ?? this.sujet,
      description: description ?? this.description,
      statutPlainte: statutPlainte ?? this.statutPlainte,
      reponse: reponse ?? this.reponse,
      dateReponse: dateReponse ?? this.dateReponse,
      imagesIds: imagesIds ?? this.imagesIds,
    );
  }
}
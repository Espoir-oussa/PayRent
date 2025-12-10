// ===============================
// 📝 Modèle de Donnée : Plainte
//
// Ce fichier définit la structure du modèle "Plainte"
// pour la couche Data de l'application PayRent.
//
// Sert à la conversion des données reçues de l'API (ou de la base de données)
// en objets Dart utilisables dans l'application.
//
// Dossier : lib/data/models/
// Rôle : Modèle de données (Data Model)
// Utilisé par : Repositories, Use Cases, Présentation
// ===============================

// TODO: Définir la classe PlainteModel selon le MLD
// Exemple de structure possible :
// class PlainteModel {
//   final String id;
//   final String description;
//   final String statutPlainte;
//   final String utilisateurId;
//   // ... autres champs
// }

// Fichier : lib/data/models/plainte_model.dart

class PlainteModel {
  final int idPlainte;
  final int idLocataire; // FK vers UTILISATEUR [cite: 30, 88]
  final int idBien; // FK vers BIEN [cite: 30, 89]
  final int idProprietaireGestionnaire; // FK vers UTILISATEUR [cite: 30, 90]
  final DateTime dateCreation;
  final String sujet;
  final String description;
  // 'Ouverte', 'Réception', 'Résolue', 'Fermée' (statuts principaux du cycle de vie) [cite: 88, 101]
  final String statutPlainte;

  PlainteModel({
    required this.idPlainte,
    required this.idLocataire,
    required this.idBien,
    required this.idProprietaireGestionnaire,
    required this.dateCreation,
    required this.sujet,
    required this.description,
    required this.statutPlainte,
  });

  PlainteModel copyWith({
    int? idPlainte,
    int? idLocataire,
    int? idBien,
    int? idProprietaireGestionnaire,
    DateTime? dateCreation,
    String? sujet,
    String? description,
    String? statutPlainte,
  }) {
    return PlainteModel(
      idPlainte: idPlainte ?? this.idPlainte,
      idLocataire: idLocataire ?? this.idLocataire,
      idBien: idBien ?? this.idBien,
      idProprietaireGestionnaire:
          idProprietaireGestionnaire ?? this.idProprietaireGestionnaire,
      dateCreation: dateCreation ?? this.dateCreation,
      sujet: sujet ?? this.sujet,
      description: description ?? this.description,
      statutPlainte: statutPlainte ?? this.statutPlainte,
    );
  }

  factory PlainteModel.fromJson(Map<String, dynamic> json) {
    return PlainteModel(
      idPlainte: json['id_plainte'],
      idLocataire: json['id_locataire'],
      idBien: json['id_bien'],
      idProprietaireGestionnaire: json['id_proprietaire_gestionnaire'],
      dateCreation: DateTime.parse(json['date_creation']),
      sujet: json['sujet'],
      description: json['description'],
      statutPlainte: json['statut_plainte'],
    );
  }

  // Utilisé par le Locataire pour déposer une nouvelle plainte
  Map<String, dynamic> toJson() {
    return {
      'id_locataire': idLocataire,
      'id_bien': idBien,
      // Le Backend doit déduire id_proprietaire_gestionnaire
      'sujet': sujet,
      'description': description,
    };
  }
}

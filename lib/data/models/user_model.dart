
// ===============================
// 👤 Modèle de Donnée : Utilisateur
//
// Ce fichier définit la structure du modèle "Utilisateur" (User)
// pour la couche Data de l'application PayRent.
//
// Sert à la conversion des données reçues de l'API (ou de la base de données)
// en objets Dart utilisables dans l'application.
//
// Dossier : lib/data/models/
// Rôle : Modèle de données (Data Model)
// Utilisé par : Repositories, Use Cases, Présentation
// ===============================

// TODO: Définir la classe UserModel selon le MLD
// Exemple de structure possible :
// class UserModel {
//   final String id;
//   final String email;
//   final String typeRole;
//   final String motDePasseHache;
//   final String? otpTemporaire;
//   // ... autres champs
// }




// Fichier : lib/data/models/user_model.dart

class UserModel {
  final int idUtilisateur;
  final String typeRole; // (ADMIN, PROPRIETAIRE, LOCATAIRE) [cite: 35]
  final String email;
  final String? motDePasseHashe; // NULLABLE* pour Locataire initial [cite: 28]
  final String? otpTemporaire; // Code à usage unique [cite: 28]
  final DateTime? otpExpiration; // Date/heure d'expiration [cite: 28]
  final String nom;
  final String prenom;
  final String? telephone;

  UserModel({
    required this.idUtilisateur,
    required this.typeRole,
    required this.email,
    required this.nom,
    required this.prenom,
    this.motDePasseHashe,
    this.otpTemporaire,
    this.otpExpiration,
    this.telephone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUtilisateur: json['id_utilisateur'],
      typeRole: json['type_role'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      motDePasseHashe: json['mot_de_passe_hashe'],
      otpTemporaire: json['otp_temporaire'],
      otpExpiration: json['otp_expiration'] != null
          ? DateTime.parse(json['otp_expiration'])
          : null,
      telephone: json['telephone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_role': typeRole,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      // Ne pas inclure les champs sensibles (mot_de_passe_hashe) dans les requêtes Get/Post générales
    };
  }
}
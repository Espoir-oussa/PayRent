// Fichier : lib/data/models/user_model.dart (CORRIGÉ)

import 'package:appwrite/models.dart' as models;
import '../../domain/entities/user_entity.dart'; // ⬅️ NOUVEL IMPORT NÉCESSAIRE

// 🔥 CORRECTION : UserModel DOIT étendre UserEntity
class UserModel extends UserEntity { 
  final String? motDePasseHashe; 
  final String? otpTemporaire; 
  final DateTime? otpExpiration; 
  final String? token; // 🔥 AJOUT DU CHAMP TOKEN
  final String? appwriteId; // ID Appwrite de l'utilisateur

  // Le constructeur reçoit tous les champs
  UserModel({
    required int idUtilisateur,
    required String typeRole,
    required String email,
    required String nom,
    required String prenom,
    String? telephone,
    // Champs spécifiques au Model
    this.motDePasseHashe, 
    this.otpTemporaire, 
    this.otpExpiration, 
    this.token, // 🔥 AJOUT DU CHAMP TOKEN
    this.appwriteId,
  // 🔥 CORRECTION : Appelle le constructeur de la classe parente (UserEntity)
  }) : super( 
          idUtilisateur: idUtilisateur,
          typeRole: typeRole,
          email: email,
          nom: nom,
          prenom: prenom,
          telephone: telephone,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUtilisateur: json['id_utilisateur'],
      typeRole: json['type_role'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      token: json['token'], // 🔥 RÉCUPÉRATION DU TOKEN
      // Note : les champs non définis dans UserEntity vont ici
      motDePasseHashe: json['mot_de_passe_hashe'],
      otpTemporaire: json['otp_temporaire'],
      otpExpiration: json['otp_expiration'] != null
          ? DateTime.parse(json['otp_expiration'])
          : null,
      telephone: json['telephone'],
    );
  }

  /// Factory pour créer un UserModel depuis un document Appwrite
  factory UserModel.fromAppwrite(models.Document doc, String appwriteUserId) {
    final data = doc.data;
    return UserModel(
      idUtilisateur: 0, // L'ID numérique n'est pas utilisé avec Appwrite
      typeRole: data['type_role'] ?? 'proprietaire',
      email: data['email'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      telephone: data['telephone'],
      appwriteId: appwriteUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_role': typeRole,
      'email': email,
      'nom': nom,
      'prenom': prenom,
    };
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'type_role': typeRole,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    };
  }
}
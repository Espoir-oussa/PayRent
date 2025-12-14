// ===============================
// 📄 Contrat Repository : Authentification
//
// Ce fichier définit l'interface (contrat) pour l'accès aux données d'authentification.
//
// Dossier : lib/domain/repositories/
// Rôle : Déclaration des méthodes d'accès aux données d'authentification
// Utilisé par : Use Cases, Data Layer
// ===============================

// TODO: Définir l'interface AuthRepository
// abstract class AuthRepository {
//   Future<User> loginWithOtp(String email, String otp);
//   // ... autres méthodes
// }


import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> loginOwner({required String email, required String password});
  Future<void> ownerLogout();
  Future<UserModel> registerOwner({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String? telephone,
  });
  // ... autres méthodes (signup, otp, etc.)
}

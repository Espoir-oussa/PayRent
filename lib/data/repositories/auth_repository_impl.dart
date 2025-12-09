
// ===============================
// 🏢 Implémentation Repository : Authentification
//
// Ce fichier contient l'implémentation concrète du repository pour l'authentification.
//
// Dossier : lib/data/repositories/
// Rôle : Accès aux données (API, base de données) pour l'authentification
// Utilisé par : Use Cases, Présentation
// ===============================

// TODO: Implémenter la classe AuthRepositoryImpl
// class AuthRepositoryImpl implements AuthRepository {
//   // ...
// }



import '../../core/services/api_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  AuthRepositoryImpl(this.apiService);

  @override
  Future<UserModel> loginOwner({required String email, required String password}) async {
    final response = await apiService.post('auth/login/owner', {
      'email': email,
      'mot_de_passe': password,
    });
    return UserModel.fromJson(response);
  }
  // ... autres implémentations
}
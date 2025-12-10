// Fichier : lib/data/repositories/auth_repository_impl.dart (VERSION CORRIGÉE)

import '../../core/services/api_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart'; // Utilisé pour mapper la réponse

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  
  AuthRepositoryImpl(this.apiService);

  @override
  // 🔥 Utilise l'Entité (UserEntity) comme type de retour
  Future<UserModel> loginOwner({required String email, required String password}) async {
    
    // 1. Appel POST vers l'API Laravel
    // 🔥 CORRECTION 1 : Endpoint mis à jour vers 'proprietaires/login'
    // 🔥 CORRECTION 2 : Le champ 'password' doit être utilisé pour Laravel
    final response = await apiService.post('proprietaires/login', {
      'email': email,
      'password': password, 
    });

    // La réponse de Laravel est : {'token': '...', 'user': {...}}
    final token = response['token'];
    final userData = response['user'];

    // 2. 🔥 GESTION DU TOKEN : Stockage du token dans l'ApiService pour les prochaines requêtes
    apiService.setAuthToken(token);

    // 3. Mappage des données utilisateur
    // On mappe le Map<String, dynamic> userData vers le UserModel
    final userModel = UserModel.fromJson(userData);
    
    // On retourne l'Entité pour respecter le contrat du domaine
    return userModel; 
  }
  
  @override
  Future<void> ownerLogout() async {
    // Suppression du token local
    apiService.setAuthToken(null);
    // Si besoin, appeler l'API pour invalider le token côté serveur
    // await apiService.post('proprietaires/logout', {});
  }

  @override
  Future<UserModel> registerOwner({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    final response = await apiService.post('proprietaires/register', {
      'email': email,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    });
    final token = response['token'];
    final userData = response['user'];
    apiService.setAuthToken(token);
    return UserModel.fromJson(userData..['token'] = token);
  }

  // TODO: Ajoutez ici les autres méthodes de AuthRepository (loginLocataire, etc.)
}
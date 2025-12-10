// Fichier : lib/data/repositories/auth_repository_appwrite.dart
// Implémentation du repository d'authentification utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../core/services/appwrite_service.dart';
import '../../config/environment.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryAppwrite implements AuthRepository {
  final AppwriteService _appwriteService;

  AuthRepositoryAppwrite(this._appwriteService);

  @override
  Future<UserModel> loginOwner({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Créer une session avec Appwrite Account
      await _appwriteService.login(email: email, password: password);

      // 2. Récupérer les infos de l'utilisateur connecté
      final user = await _appwriteService.getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non trouvé après connexion');
      }

      // 3. Récupérer le profil utilisateur depuis la collection users
      final userProfile = await _getUserProfile(user.$id);

      return userProfile;
    } on AppwriteException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    }
  }

  @override
  Future<void> ownerLogout() async {
    try {
      await _appwriteService.logout();
    } on AppwriteException catch (e) {
      throw Exception('Erreur de déconnexion: ${e.message}');
    }
  }

  @override
  Future<UserModel> registerOwner({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    try {
      // 1. Créer le compte Appwrite
      final user = await _appwriteService.createAccount(
        email: email,
        password: password,
        name: '$prenom $nom',
      );

      // 2. Connecter l'utilisateur automatiquement
      await _appwriteService.login(email: email, password: password);

      // 3. Créer le profil utilisateur dans la base de données
      final userDoc = await _appwriteService.createDocument(
        collectionId: Environment.usersCollectionId,
        documentId: user.$id, // Utiliser le même ID que le compte
        data: {
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'type_role': 'proprietaire',
          'date_creation': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.update(Role.user(user.$id)),
        ],
      );

      return UserModel.fromAppwrite(userDoc, user.$id);
    } on AppwriteException catch (e) {
      throw Exception('Erreur d\'inscription: ${e.message}');
    }
  }

  /// Récupérer le profil utilisateur depuis la collection users
  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final doc = await _appwriteService.getDocument(
        collectionId: Environment.usersCollectionId,
        documentId: userId,
      );
      return UserModel.fromAppwrite(doc, userId);
    } on AppwriteException catch (e) {
      // Si le profil n'existe pas, créer un profil basique
      if (e.code == 404) {
        final user = await _appwriteService.getCurrentUser();
        if (user != null) {
          // Créer le profil avec les infos du compte
          final nameParts = user.name.split(' ');
          final prenom = nameParts.isNotEmpty ? nameParts.first : '';
          final nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          final doc = await _appwriteService.createDocument(
            collectionId: Environment.usersCollectionId,
            documentId: userId,
            data: {
              'email': user.email,
              'nom': nom,
              'prenom': prenom,
              'type_role': 'proprietaire',
              'date_creation': DateTime.now().toIso8601String(),
            },
            permissions: [
              Permission.read(Role.user(userId)),
              Permission.update(Role.user(userId)),
            ],
          );
          return UserModel.fromAppwrite(doc, userId);
        }
      }
      throw Exception('Erreur récupération profil: ${e.message}');
    }
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _appwriteService.isLoggedIn();
  }

  /// Récupérer l'utilisateur courant
  Future<UserModel?> getCurrentUser() async {
    final user = await _appwriteService.getCurrentUser();
    if (user == null) return null;

    try {
      return await _getUserProfile(user.$id);
    } catch (e) {
      return null;
    }
  }
}

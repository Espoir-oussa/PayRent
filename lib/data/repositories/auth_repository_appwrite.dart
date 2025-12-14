// Fichier : lib/data/repositories/auth_repository_appwrite.dart
// Implémentation du repository d'authentification utilisant Appwrite

import 'package:appwrite/appwrite.dart';
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
      // 0. Fermer toute session existante avant de se connecter
      try {
        await _appwriteService.logout();
      } catch (_) {
        // Ignorer l'erreur si pas de session active
      }

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
      // 0. Fermer toute session existante avant l'inscription
      try {
        await _appwriteService.logout();
      } catch (_) {
        // Ignorer l'erreur si pas de session active
      }

      // 1. Créer le compte Appwrite
      final user = await _appwriteService.createAccount(
        email: email,
        password: password,
        name: '$prenom $nom',
      );

      // 2. Connecter l'utilisateur automatiquement
      await _appwriteService.login(email: email, password: password);

      // 3. Créer le profil utilisateur dans la base de données
      try {
        final userDoc = await _appwriteService.createDocument(
          collectionId: Environment.usersCollectionId,
          documentId: user.$id, // Utiliser le même ID que le compte
          data: {
            'email': email,
            'nom': nom,
            'prenom': prenom,
            'telephone': telephone ?? '',
            'role': 'proprietaire',
            'adresse': '',
            'photoUrl': '',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          permissions: [
            Permission.read(Role.user(user.$id)),
            Permission.update(Role.user(user.$id)),
          ],
        );

        return UserModel.fromAppwrite(userDoc, user.$id);
      } on AppwriteException catch (e) {
        // Si le document existe déjà (conflit), récupérer le document existant
        final message = e.message?.toLowerCase() ?? '';
        if (e.code == 409 || message.contains('already') || message.contains('requested id')) {
          final existing = await _appwriteService.getDocument(
            collectionId: Environment.usersCollectionId,
            documentId: user.$id,
          );
          return UserModel.fromAppwrite(existing, user.$id);
        }
        throw Exception('Erreur d\'inscription: ${e.message}');
      }
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

          try {
            final doc = await _appwriteService.createDocument(
              collectionId: Environment.usersCollectionId,
              documentId: userId,
              data: {
                'email': user.email,
                'nom': nom,
                'prenom': prenom,
                'telephone': '',
                'role': 'proprietaire',
                'adresse': '',
                'photoUrl': '',
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
              permissions: [
                Permission.read(Role.user(userId)),
                Permission.update(Role.user(userId)),
              ],
            );
            return UserModel.fromAppwrite(doc, userId);
          } on AppwriteException catch (e) {
            final message = e.message?.toLowerCase() ?? '';
            // Si conflit (document déjà créé par une autre requête concurrente), récupérer le document existant
            if (e.code == 409 || message.contains('already') || message.contains('requested id')) {
              final existing = await _appwriteService.getDocument(
                collectionId: Environment.usersCollectionId,
                documentId: userId,
              );
              return UserModel.fromAppwrite(existing, userId);
            }
            rethrow;
          }
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

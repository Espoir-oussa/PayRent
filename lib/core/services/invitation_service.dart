// Fichier : lib/core/services/invitation_service.dart
// Service pour gérer les invitations de locataires

import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/bien_model.dart';
import 'appwrite_service.dart';
import 'email_service.dart';

/// Résultat d'une création d'invitation, contenant l'invitation et si l'email a bien été envoyé
class InvitationResult {
  final InvitationModel invitation;
  final bool targetUserExists;

  InvitationResult({required this.invitation, required this.targetUserExists});
}

class InvitationService {
  final AppwriteService _appwriteService;
  InvitationService(this._appwriteService);

  /// Générer un token unique pour l'invitation
  String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(48, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Générer un mot de passe temporaire sécurisé
  String _generateTemporaryPassword() {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '@#\$%&*!';
    
    final random = Random.secure();
    final password = StringBuffer();
    
    // Au moins une de chaque catégorie
    password.write(lowercase[random.nextInt(lowercase.length)]);
    password.write(uppercase[random.nextInt(uppercase.length)]);
    password.write(numbers[random.nextInt(numbers.length)]);
    password.write(special[random.nextInt(special.length)]);
    
    // Compléter avec des caractères aléatoires
    const allChars = lowercase + uppercase + numbers;
    for (var i = 0; i < 8; i++) {
      password.write(allChars[random.nextInt(allChars.length)]);
    }
    
    // Mélanger le mot de passe
    final chars = password.toString().split('');
    chars.shuffle(random);
    return chars.join();
  }

  /// Résultat d'une création d'invitation
  

  /// Créer et envoyer une invitation
  Future<InvitationResult> createInvitation({
    required BienModel bien,
    required String emailLocataire,
    String? nomLocataire,
    String? prenomLocataire,
    String? telephoneLocataire,
    String? message,
    int expirationDays = 7,
  }) async {
    try {
      // Récupérer l'utilisateur courant (propriétaire)
      final currentUser = await _appwriteService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Vous devez être connecté pour envoyer une invitation');
      }

      // Récupérer le profil du propriétaire
      final proprietaireDoc = await _appwriteService.getDocument(
        collectionId: Environment.usersCollectionId,
        documentId: currentUser.$id,
      );
      final proprietaireNom = '${proprietaireDoc.data['prenom'] ?? ''} ${proprietaireDoc.data['nom'] ?? ''}'.trim();

      // Debug: log bien id
      debugPrint('createInvitation: bien.appwriteId=${bien.appwriteId}');

      // Le bien doit avoir un ID Appwrite valide
      if (bien.appwriteId == null || bien.appwriteId!.trim().isEmpty) {
        throw Exception('Le bien doit être enregistré avant d\'envoyer une invitation');
      }

      // Vérifier si une invitation en attente existe déjà pour cet email et ce bien
      final existingInvitations = await _appwriteService.listDocuments(
        collectionId: Environment.invitationsCollectionId,
        queries: [
          Query.equal('bienId', bien.appwriteId),
          Query.equal('emailLocataire', emailLocataire),
          Query.equal('statut', 'pending'),
        ],
      );

      if (existingInvitations.documents.isNotEmpty) {
        throw Exception('Une invitation est déjà en attente pour cet email');
      }

      // Vérifier si l'email cible possède déjà un compte dans la collection users
      final usersCheck = await _appwriteService.listDocuments(
        collectionId: Environment.usersCollectionId,
        queries: [Query.equal('email', emailLocataire)],
      );
      if (usersCheck.documents.isEmpty) {
        // Ne pas créer ni envoyer une invitation pour un email qui n'est pas associé à un utilisateur
        throw Exception("L'email $emailLocataire n'est pas associé à un utilisateur PayRent. Aucune invitation ne sera créée ni envoyée.");
      }

      // Créer le token unique
      final token = _generateToken();
      final now = DateTime.now();
      final expiration = now.add(Duration(days: expirationDays));

      // Créer l'invitation
      final invitation = InvitationModel(
        bienId: bien.appwriteId ?? '',
        bienNom: bien.nom,
        proprietaireId: currentUser.$id,
        proprietaireNom: proprietaireNom,
        emailLocataire: emailLocataire,
        nomLocataire: nomLocataire,
        prenomLocataire: prenomLocataire,
        telephoneLocataire: telephoneLocataire,
        token: token,
        dateCreation: now,
        dateExpiration: expiration,
        loyerMensuel: bien.loyerMensuel,
        charges: bien.charges,
        message: message,
      );

      // Sauvegarder dans Appwrite
      final doc = await _appwriteService.createDocument(
        collectionId: Environment.invitationsCollectionId,
        data: invitation.toAppwrite(),
        permissions: [
          Permission.read(Role.user(currentUser.$id)),
          Permission.update(Role.user(currentUser.$id)),
          Permission.delete(Role.user(currentUser.$id)),
          // L'invitation sera aussi lisible par anyone pour la validation du token
          Permission.read(Role.any()),
        ],
      );

      // Créer une notification in-app pour l'utilisateur ciblé (pas d'email)
      try {
        if (usersCheck.documents.isNotEmpty) {
          final targetUserId = usersCheck.documents.first.$id;

          await _appwriteService.createDocument(
            collectionId: Environment.notificationsCollectionId,
            data: {
              'userId': targetUserId,
              'title': 'Nouvelle invitation',
              'body': 'Vous avez reçu une invitation pour ${bien.nom}',
              'data': {
                'token': token,
                'bienId': bien.appwriteId,
              },
              'isRead': false,
              'createdAt': DateTime.now().toIso8601String(),
            },
            documentId: ID.unique(),
          );
        }
      } catch (e) {
        debugPrint('Erreur création notification in-app: $e');
      }

      return InvitationResult(invitation: InvitationModel.fromAppwrite(doc), targetUserExists: true);
    } on AppwriteException catch (e) {
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('invalid query') || msg.contains('equal queries require')) {
        throw Exception('Erreur lors de la création de l\'invitation: identifiant du bien invalide (bienId vide ou incorrect)');
      }
      throw Exception('Erreur lors de la création de l\'invitation: ${e.message}');
    }
  }

  /// Construire le lien d'invitation
  String _buildInvitationLink(String token) {
    // Pour le web: https://payrent.app/accept-invitation?token=xxx
    // Pour l'app mobile: payrent://accept-invitation?token=xxx
    return 'payrent://accept-invitation?token=$token';
  }

  /// Récupérer une invitation par son token
  Future<InvitationModel?> getInvitationByToken(String token) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.invitationsCollectionId,
        queries: [Query.equal('token', token)],
      );

      if (result.documents.isEmpty) {
        return null;
      }

      return InvitationModel.fromAppwrite(result.documents.first);
    } on AppwriteException catch (e) {
      debugPrint('Erreur récupération invitation: ${e.message}');
      return null;
    }
  }

  /// Récupérer les invitations d'un propriétaire
  Future<List<InvitationModel>> getInvitationsByProprietaire(String proprietaireId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.invitationsCollectionId,
        queries: [
          Query.equal('proprietaireId', proprietaireId),
          Query.orderDesc('dateCreation'),
        ],
      );

      return result.documents
          .map((doc) => InvitationModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des invitations: ${e.message}');
    }
  }

  /// Récupérer les invitations pour un bien spécifique
  Future<List<InvitationModel>> getInvitationsByBien(String bienId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.invitationsCollectionId,
        queries: [
          Query.equal('bienId', bienId),
          Query.orderDesc('dateCreation'),
        ],
      );

      return result.documents
          .map((doc) => InvitationModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des invitations: ${e.message}');
    }
  }

  /// Récupérer les invitations en attente pour un bien
  Future<List<InvitationModel>> getPendingInvitationsByBien(String bienId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.invitationsCollectionId,
        queries: [
          Query.equal('bienId', bienId),
          Query.equal('statut', 'pending'),
          Query.orderDesc('dateCreation'),
        ],
      );

      return result.documents
          .map((doc) => InvitationModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des invitations: ${e.message}');
    }
  }

  /// Accepter une invitation (côté locataire)
  /// Crée le compte locataire et le contrat
  Future<UserModel> acceptInvitation({
    required String token,
    required String password,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    try {
      // 1. Récupérer l'invitation
      final invitation = await getInvitationByToken(token);
      if (invitation == null) {
        throw Exception('Invitation non trouvée');
      }

      if (!invitation.canBeAccepted) {
        if (invitation.isExpired) {
          throw Exception('Cette invitation a expiré');
        }
        throw Exception('Cette invitation n\'est plus valide');
      }

      // 2. Créer le compte Appwrite pour le locataire
      final user = await _appwriteService.createAccount(
        email: invitation.emailLocataire,
        password: password,
        name: '$prenom $nom',
      );

      // 3. Connecter le nouveau locataire
      await _appwriteService.login(
        email: invitation.emailLocataire,
        password: password,
      );

      // 4. Créer le profil utilisateur dans la collection users
      Map<String, dynamic> userDocData = {
        'email': invitation.emailLocataire,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone ?? invitation.telephoneLocataire ?? '',
        'role': 'locataire',
        'adresse': '',
        'photoUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      late models.Document createdUserDoc;
      try {
        final userDoc = await _appwriteService.createDocument(
          collectionId: Environment.usersCollectionId,
          documentId: user.$id,
          data: userDocData,
          permissions: [
            Permission.read(Role.user(user.$id)),
            Permission.update(Role.user(user.$id)),
            // Le propriétaire peut aussi lire le profil
            Permission.read(Role.user(invitation.proprietaireId)),
          ],
        );
        createdUserDoc = userDoc;
      } on AppwriteException catch (e) {
        final message = e.message?.toLowerCase() ?? '';
        if (e.code == 409 || message.contains('already') || message.contains('requested id')) {
          // Document existant : récupérer et continuer
          final existing = await _appwriteService.getDocument(
            collectionId: Environment.usersCollectionId,
            documentId: user.$id,
          );
          createdUserDoc = existing;
        } else {
          rethrow;
        }
      }

      // 5. Créer le contrat de location
      await _appwriteService.createDocument(
        collectionId: Environment.contratsCollectionId,
        data: {
          'bienId': invitation.bienId,
          'locataireId': user.$id,
          'proprietaireId': invitation.proprietaireId,
          'dateDebut': DateTime.now().toIso8601String(),
          'dateFin': null,
          'loyerMensuel': invitation.loyerMensuel,
          'charges': invitation.charges ?? 0,
          'caution': 0,
          'jourPaiement': 1,
          'statut': 'actif',
          'documentUrl': null,
          'notes': invitation.message,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.read(Role.user(invitation.proprietaireId)),
          Permission.update(Role.user(invitation.proprietaireId)),
        ],
      );

      // 6. Mettre à jour le statut de l'invitation
      await _appwriteService.updateDocument(
        collectionId: Environment.invitationsCollectionId,
        documentId: invitation.id!,
        data: {'statut': 'accepted'},
      );

      // 7. Mettre à jour le bien avec le locataire
      await _appwriteService.updateDocument(
        collectionId: Environment.biensCollectionId,
        documentId: invitation.bienId,
        data: {
          'locataireId': user.$id,
          'statut': 'occupe',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return UserModel.fromAppwrite(createdUserDoc, user.$id);
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors de l\'acceptation: ${e.message}');
    }
  }

  /// Accepter une invitation en utilisant un mot de passe temporaire (deep link)
  Future<Map<String, dynamic>> acceptInvitationWithPassword({
    required String token,
    required String temporaryPassword,
  }) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null) throw Exception('Invitation non trouvée');

      if (!invitation.canBeAccepted) {
        if (invitation.isExpired) throw Exception('Cette invitation a expiré');
        throw Exception('Cette invitation n\'est plus valide');
      }

      final nom = invitation.nomLocataire ?? 'Locataire';
      final prenom = invitation.prenomLocataire ?? '';
      final fullName = '$prenom $nom'.trim();

      try {
        // Tenter de créer le compte avec le mot de passe temporaire
        final user = await _appwriteService.createAccount(
          email: invitation.emailLocataire,
          password: temporaryPassword,
          name: fullName,
        );

        // Se connecter
        await _appwriteService.login(email: invitation.emailLocataire, password: temporaryPassword);

        // Créer le profil utilisateur
        late models.Document userDoc;
        try {
          userDoc = await _appwriteService.createDocument(
            collectionId: Environment.usersCollectionId,
            documentId: user.$id,
            data: {
              'email': invitation.emailLocataire,
              'nom': nom,
              'prenom': prenom,
              'telephone': invitation.telephoneLocataire ?? '',
              'role': 'locataire',
              'adresse': '',
              'photoUrl': '',
              'mustChangePassword': true,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            permissions: [
              Permission.read(Role.user(user.$id)),
              Permission.update(Role.user(user.$id)),
              Permission.read(Role.user(invitation.proprietaireId)),
            ],
          );
        } on AppwriteException catch (e) {
          final message = e.message?.toLowerCase() ?? '';
          if (e.code == 409 || message.contains('already') || message.contains('requested id')) {
            userDoc = await _appwriteService.getDocument(
              collectionId: Environment.usersCollectionId,
              documentId: user.$id,
            );
          } else {
            rethrow;
          }
        }

        // Créer le contrat
        await _appwriteService.createDocument(
          collectionId: Environment.contratsCollectionId,
          data: {
            'bienId': invitation.bienId,
            'locataireId': user.$id,
            'proprietaireId': invitation.proprietaireId,
            'dateDebut': DateTime.now().toIso8601String(),
            'dateFin': null,
            'loyerMensuel': invitation.loyerMensuel,
            'charges': invitation.charges ?? 0,
            'caution': 0,
            'jourPaiement': 1,
            'statut': 'actif',
            'documentUrl': null,
            'notes': invitation.message,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          permissions: [
            Permission.read(Role.user(user.$id)),
            Permission.read(Role.user(invitation.proprietaireId)),
            Permission.update(Role.user(invitation.proprietaireId)),
          ],
        );

        // Mettre à jour l'invitation et le bien
        await _appwriteService.updateDocument(
          collectionId: Environment.invitationsCollectionId,
          documentId: invitation.id!,
          data: {'statut': 'accepted'},
        );

        await _appwriteService.updateDocument(
          collectionId: Environment.biensCollectionId,
          documentId: invitation.bienId,
          data: {'locataireId': user.$id, 'statut': 'occupe', 'updatedAt': DateTime.now().toIso8601String()},
        );

        return {'user': UserModel.fromAppwrite(userDoc, user.$id), 'temporaryPassword': temporaryPassword};
      } on AppwriteException catch (e) {
        final msg = e.message?.toLowerCase() ?? '';
        if (msg.contains('already') || msg.contains('exists') || msg.contains('user_already_exists')) {
          // Compte existe déjà : essayer de se connecter avec le mot de passe temporaire
          try {
            await _appwriteService.login(email: invitation.emailLocataire, password: temporaryPassword);
            final currentUser = await _appwriteService.getCurrentUser();
            if (currentUser == null) throw Exception('Impossible de récupérer l\'utilisateur après login');

            // Créer le contrat si nécessaire
            await _appwriteService.createDocument(
              collectionId: Environment.contratsCollectionId,
              data: {
                'bienId': invitation.bienId,
                'locataireId': currentUser.$id,
                'proprietaireId': invitation.proprietaireId,
                'dateDebut': DateTime.now().toIso8601String(),
                'dateFin': null,
                'loyerMensuel': invitation.loyerMensuel,
                'charges': invitation.charges ?? 0,
                'caution': 0,
                'jourPaiement': 1,
                'statut': 'actif',
                'documentUrl': null,
                'notes': invitation.message,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
              permissions: [
                Permission.read(Role.user(currentUser.$id)),
                Permission.read(Role.user(invitation.proprietaireId)),
                Permission.update(Role.user(invitation.proprietaireId)),
              ],
            );

            await _appwriteService.updateDocument(collectionId: Environment.invitationsCollectionId, documentId: invitation.id!, data: {'statut': 'accepted'});
            await _appwriteService.updateDocument(collectionId: Environment.biensCollectionId, documentId: invitation.bienId, data: {'locataireId': currentUser.$id, 'statut': 'occupe', 'updatedAt': DateTime.now().toIso8601String()});

            final userDoc = await _appwriteService.getDocument(collectionId: Environment.usersCollectionId, documentId: currentUser.$id);
            return {'user': UserModel.fromAppwrite(userDoc, currentUser.$id)};
          } on AppwriteException catch (_) {
            // Échec de connexion, envoyer recovery
            await _appwriteService.createRecovery(email: invitation.emailLocataire, url: Environment.appwritePublicEndpoint);
            throw Exception('Un compte existe déjà. Un email de récupération a été envoyé.');
          }
        }
        rethrow;
      }
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors de l\'acceptation: ${e.message}');
    }
  }

  /// Refuser une invitation
  Future<void> rejectInvitation(String token) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null) {
        throw Exception('Invitation non trouvée');
      }

      await _appwriteService.updateDocument(
        collectionId: Environment.invitationsCollectionId,
        documentId: invitation.id!,
        data: {'statut': 'rejected'},
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors du refus: ${e.message}');
    }
  }

  /// Accepter une invitation si le locataire a déjà un compte (connexion existante)
  Future<void> acceptInvitationWithExistingAccount({
    required String token,
    required String locataireId,
  }) async {
    try {
      final invitation = await getInvitationByToken(token);
      if (invitation == null) throw Exception('Invitation non trouvée');
      if (!invitation.canBeAccepted) {
        if (invitation.isExpired) throw Exception('Cette invitation a expiré');
        throw Exception('Cette invitation n\'est plus valide');
      }

      // Créer le contrat
      await _appwriteService.createDocument(
        collectionId: Environment.contratsCollectionId,
        data: {
          'bienId': invitation.bienId,
          'locataireId': locataireId,
          'proprietaireId': invitation.proprietaireId,
          'dateDebut': DateTime.now().toIso8601String(),
          'dateFin': null,
          'loyerMensuel': invitation.loyerMensuel,
          'charges': invitation.charges ?? 0,
          'caution': 0,
          'jourPaiement': 1,
          'statut': 'actif',
          'documentUrl': null,
          'notes': invitation.message,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(locataireId)),
          Permission.read(Role.user(invitation.proprietaireId)),
          Permission.update(Role.user(invitation.proprietaireId)),
        ],
      );

      // Mettre à jour l'invitation et le bien
      await _appwriteService.updateDocument(
        collectionId: Environment.invitationsCollectionId,
        documentId: invitation.id!,
        data: {'statut': 'accepted'},
      );

      await _appwriteService.updateDocument(
        collectionId: Environment.biensCollectionId,
        documentId: invitation.bienId,
        data: {
          'locataireId': locataireId,
          'statut': 'occupe',
          'updatedAt': DateTime.now().toIso8601String()
        },
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors de l\'acceptation: ${e.message}');
    }
  }

  /// Annuler une invitation (côté propriétaire)
  Future<void> cancelInvitation(String invitationId) async {
    try {
      await _appwriteService.updateDocument(
        collectionId: Environment.invitationsCollectionId,
        documentId: invitationId,
        data: {'statut': 'cancelled'},
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors de l\'annulation: ${e.message}');
    }
  }

  /// Renvoyer une invitation (créer une nouvelle avec nouveau token)
  Future<InvitationModel> resendInvitation(String invitationId) async {
    try {
      // Récupérer l'ancienne invitation
      final oldInvitationDoc = await _appwriteService.getDocument(
        collectionId: Environment.invitationsCollectionId,
        documentId: invitationId,
      );
      final oldInvitation = InvitationModel.fromAppwrite(oldInvitationDoc);

      // Annuler l'ancienne
      await cancelInvitation(invitationId);

      // Récupérer le bien
      final bienDoc = await _appwriteService.getDocument(
        collectionId: Environment.biensCollectionId,
        documentId: oldInvitation.bienId,
      );
      final bien = BienModel.fromAppwrite(bienDoc);

      // Créer une nouvelle invitation
      final result = await createInvitation(
        bien: bien,
        emailLocataire: oldInvitation.emailLocataire,
        nomLocataire: oldInvitation.nomLocataire,
        prenomLocataire: oldInvitation.prenomLocataire,
        telephoneLocataire: oldInvitation.telephoneLocataire,
        message: oldInvitation.message,
      );
      return result.invitation;
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors du renvoi: ${e.message}');
    }
  }

  /// Supprimer une invitation
  Future<void> deleteInvitation(String invitationId) async {
    try {
      await _appwriteService.deleteDocument(
        collectionId: Environment.invitationsCollectionId,
        documentId: invitationId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur lors de la suppression: ${e.message}');
    }
  }
}

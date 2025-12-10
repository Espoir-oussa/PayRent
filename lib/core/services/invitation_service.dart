// Fichier : lib/core/services/invitation_service.dart
// Service pour gérer les invitations de locataires

import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/bien_model.dart';
import 'appwrite_service.dart';
import 'email_service.dart';

class InvitationService {
  final AppwriteService _appwriteService;
  final EmailService _emailService = EmailService();

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

  /// Créer et envoyer une invitation
  Future<InvitationModel> createInvitation({
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

      // Envoyer l'email d'invitation automatiquement
      final recipientName = [prenomLocataire, nomLocataire]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      
      final emailSent = await _emailService.sendInvitationEmail(
        recipientEmail: emailLocataire,
        recipientName: recipientName,
        proprietaireNom: proprietaireNom,
        bienNom: bien.nom,
        token: token,
        loyerMensuel: bien.loyerMensuel,
        charges: bien.charges,
        messagePersonnalise: message,
      );

      if (emailSent) {
        debugPrint('📧 Email d\'invitation envoyé à $emailLocataire');
      } else {
        debugPrint('⚠️ Échec de l\'envoi de l\'email, mais l\'invitation a été créée');
      }

      // Log le lien pour le développement
      final invitationLink = _buildInvitationLink(token);
      debugPrint('🔗 Lien d\'invitation: $invitationLink');

      return InvitationModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
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
      final userDoc = await _appwriteService.createDocument(
        collectionId: Environment.usersCollectionId,
        documentId: user.$id,
        data: {
          'email': invitation.emailLocataire,
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone ?? invitation.telephoneLocataire ?? '',
          'role': 'locataire',
          'adresse': '',
          'photoUrl': '',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.update(Role.user(user.$id)),
          // Le propriétaire peut aussi lire le profil
          Permission.read(Role.user(invitation.proprietaireId)),
        ],
      );

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

      return UserModel.fromAppwrite(userDoc, user.$id);
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
      return await createInvitation(
        bien: bien,
        emailLocataire: oldInvitation.emailLocataire,
        nomLocataire: oldInvitation.nomLocataire,
        prenomLocataire: oldInvitation.prenomLocataire,
        telephoneLocataire: oldInvitation.telephoneLocataire,
        message: oldInvitation.message,
      );
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

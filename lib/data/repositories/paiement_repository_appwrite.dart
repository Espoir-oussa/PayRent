// Fichier : lib/data/repositories/paiement_repository_appwrite.dart
// Implémentation du repository des paiements utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../config/environment.dart';
import '../../domain/repositories/paiement_repository.dart';
import '../models/paiement_model.dart';

class PaiementRepositoryAppwrite implements PaiementRepository {
  final AppwriteService _appwriteService;

  PaiementRepositoryAppwrite(this._appwriteService);

  @override
  Future<List<PaiementModel>> getPaiementsByContrat(String contratId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.paiementsCollectionId,
        queries: [
          Query.equal('id_contrat', contratId),
          Query.orderDesc('date_paiement'),
        ],
      );

      return result.documents
          .map((doc) => PaiementModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des paiements: ${e.message}');
    }
  }

  @override
  Future<List<PaiementModel>> getPaiementsByLocataire(String locataireId) async {
    try {
      // D'abord récupérer les contrats du locataire
      final contratsResult = await _appwriteService.listDocuments(
        collectionId: Environment.contratsCollectionId,
        queries: [Query.equal('id_locataire', locataireId)],
      );

      if (contratsResult.documents.isEmpty) return [];

      final contratsIds = contratsResult.documents.map((doc) => doc.$id).toList();

      // Ensuite récupérer les paiements de ces contrats
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.paiementsCollectionId,
        queries: [
          Query.equal('id_contrat', contratsIds),
          Query.orderDesc('date_paiement'),
        ],
      );

      return result.documents
          .map((doc) => PaiementModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des paiements: ${e.message}');
    }
  }

  @override
  Future<PaiementModel> getPaiementById(String paiementId) async {
    try {
      final doc = await _appwriteService.getDocument(
        collectionId: Environment.paiementsCollectionId,
        documentId: paiementId,
      );
      return PaiementModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération du paiement: ${e.message}');
    }
  }

  @override
  Future<PaiementModel> createPaiement(PaiementModel paiement) async {
    try {
      final currentUser = await _appwriteService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _appwriteService.createDocument(
        collectionId: Environment.paiementsCollectionId,
        data: paiement.toAppwrite(),
        permissions: [
          Permission.read(Role.user(currentUser.$id)),
          Permission.update(Role.user(currentUser.$id)),
        ],
      );

      return PaiementModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur création du paiement: ${e.message}');
    }
  }

  @override
  Future<PaiementModel> updatePaiementStatut(String paiementId, String statut) async {
    try {
      final doc = await _appwriteService.updateDocument(
        collectionId: Environment.paiementsCollectionId,
        documentId: paiementId,
        data: {'statut': statut},
      );
      return PaiementModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur mise à jour du paiement: ${e.message}');
    }
  }

  @override
  Future<List<PaiementModel>> getPaiementsByStatut(String statut) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.paiementsCollectionId,
        queries: [
          Query.equal('statut', statut),
          Query.orderDesc('date_paiement'),
        ],
      );

      return result.documents
          .map((doc) => PaiementModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des paiements: ${e.message}');
    }
  }

  @override
  Future<List<PaiementModel>> getPaiementsByMois(String moisConcerne) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.paiementsCollectionId,
        queries: [
          Query.equal('mois_concerne', moisConcerne),
          Query.orderDesc('date_paiement'),
        ],
      );

      return result.documents
          .map((doc) => PaiementModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des paiements: ${e.message}');
    }
  }

  @override
  Future<bool> paiementExistePourMois(String contratId, String moisConcerne) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.paiementsCollectionId,
        queries: [
          Query.equal('id_contrat', contratId),
          Query.equal('mois_concerne', moisConcerne),
          Query.equal('statut', 'Réussi'),
          Query.limit(1),
        ],
      );

      return result.documents.isNotEmpty;
    } on AppwriteException catch (e) {
      throw Exception('Erreur vérification du paiement: ${e.message}');
    }
  }
}

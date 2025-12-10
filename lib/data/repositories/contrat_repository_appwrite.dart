// Fichier : lib/data/repositories/contrat_repository_appwrite.dart
// Implémentation du repository des contrats utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../config/environment.dart';
import '../../domain/repositories/contrat_repository.dart';
import '../models/contrat_location_model.dart';

class ContratRepositoryAppwrite implements ContratRepository {
  final AppwriteService _appwriteService;

  ContratRepositoryAppwrite(this._appwriteService);

  @override
  Future<List<ContratLocationModel>> getContratsByProprietaire(String proprietaireId) async {
    try {
      // D'abord récupérer les biens du propriétaire
      final biensResult = await _appwriteService.listDocuments(
        collectionId: Environment.biensCollectionId,
        queries: [Query.equal('id_proprietaire', proprietaireId)],
      );

      if (biensResult.documents.isEmpty) return [];

      final biensIds = biensResult.documents.map((doc) => doc.$id).toList();

      // Ensuite récupérer les contrats de ces biens
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.contratsCollectionId,
        queries: [
          Query.equal('id_bien', biensIds),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => ContratLocationModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des contrats: ${e.message}');
    }
  }

  @override
  Future<List<ContratLocationModel>> getContratsByLocataire(String locataireId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.contratsCollectionId,
        queries: [
          Query.equal('id_locataire', locataireId),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => ContratLocationModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des contrats: ${e.message}');
    }
  }

  @override
  Future<List<ContratLocationModel>> getContratsByBien(String bienId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.contratsCollectionId,
        queries: [
          Query.equal('id_bien', bienId),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => ContratLocationModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des contrats: ${e.message}');
    }
  }

  @override
  Future<ContratLocationModel> getContratById(String contratId) async {
    try {
      final doc = await _appwriteService.getDocument(
        collectionId: Environment.contratsCollectionId,
        documentId: contratId,
      );
      return ContratLocationModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération du contrat: ${e.message}');
    }
  }

  @override
  Future<ContratLocationModel> createContrat(ContratLocationModel contrat) async {
    try {
      final currentUser = await _appwriteService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _appwriteService.createDocument(
        collectionId: Environment.contratsCollectionId,
        data: contrat.toAppwrite(),
        permissions: [
          Permission.read(Role.user(currentUser.$id)),
          Permission.update(Role.user(currentUser.$id)),
          Permission.read(Role.user(contrat.idLocataire)),
        ],
      );

      return ContratLocationModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur création du contrat: ${e.message}');
    }
  }

  @override
  Future<ContratLocationModel> updateContrat(String contratId, ContratLocationModel contrat) async {
    try {
      final doc = await _appwriteService.updateDocument(
        collectionId: Environment.contratsCollectionId,
        documentId: contratId,
        data: contrat.toAppwrite(),
      );
      return ContratLocationModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur mise à jour du contrat: ${e.message}');
    }
  }

  @override
  Future<void> resilierContrat(String contratId) async {
    try {
      await _appwriteService.updateDocument(
        collectionId: Environment.contratsCollectionId,
        documentId: contratId,
        data: {
          'statut': 'resilie',
          'date_fin_prevue': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur résiliation du contrat: ${e.message}');
    }
  }

  @override
  Future<ContratLocationModel?> getContratActifByLocataire(String locataireId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.contratsCollectionId,
        queries: [
          Query.equal('id_locataire', locataireId),
          Query.equal('statut', 'actif'),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) return null;
      return ContratLocationModel.fromAppwrite(result.documents.first);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération du contrat actif: ${e.message}');
    }
  }
}

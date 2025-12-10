// Fichier : lib/data/repositories/plainte_repository_appwrite.dart
// Implémentation du repository des plaintes utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../config/environment.dart';
import '../../domain/repositories/plainte_repository.dart';
import '../models/plainte_model.dart';

class PlainteRepositoryAppwrite implements PlainteRepository {
  final AppwriteService _appwriteService;

  PlainteRepositoryAppwrite(this._appwriteService);

  @override
  Future<List<PlainteModel>> getPlaintesByProprietaire(String proprietaireId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.plaintesCollectionId,
        queries: [
          Query.equal('id_proprietaire_gestionnaire', proprietaireId),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => PlainteModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des plaintes: ${e.message}');
    }
  }

  @override
  Future<List<PlainteModel>> getPlaintesByLocataire(String locataireId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.plaintesCollectionId,
        queries: [
          Query.equal('id_locataire', locataireId),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => PlainteModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des plaintes: ${e.message}');
    }
  }

  @override
  Future<List<PlainteModel>> getPlaintesByBien(String bienId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.plaintesCollectionId,
        queries: [
          Query.equal('id_bien', bienId),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => PlainteModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des plaintes: ${e.message}');
    }
  }

  @override
  Future<PlainteModel> getPlainteById(String plainteId) async {
    try {
      final doc = await _appwriteService.getDocument(
        collectionId: Environment.plaintesCollectionId,
        documentId: plainteId,
      );
      return PlainteModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération de la plainte: ${e.message}');
    }
  }

  @override
  Future<PlainteModel> createPlainte(PlainteModel plainte) async {
    try {
      final currentUser = await _appwriteService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _appwriteService.createDocument(
        collectionId: Environment.plaintesCollectionId,
        data: plainte.toAppwrite(),
        permissions: [
          Permission.read(Role.user(currentUser.$id)),
          Permission.update(Role.user(currentUser.$id)),
          Permission.read(Role.user(plainte.idProprietaireGestionnaire)),
          Permission.update(Role.user(plainte.idProprietaireGestionnaire)),
        ],
      );

      return PlainteModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur création de la plainte: ${e.message}');
    }
  }

  @override
  Future<PlainteModel> updatePlainteStatut(String plainteId, String newStatus) async {
    try {
      final doc = await _appwriteService.updateDocument(
        collectionId: Environment.plaintesCollectionId,
        documentId: plainteId,
        data: {'statut_plainte': newStatus},
      );
      return PlainteModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur mise à jour de la plainte: ${e.message}');
    }
  }

  @override
  Future<PlainteModel> repondrePlainte(String plainteId, String reponse) async {
    try {
      final doc = await _appwriteService.updateDocument(
        collectionId: Environment.plaintesCollectionId,
        documentId: plainteId,
        data: {
          'reponse': reponse,
          'date_reponse': DateTime.now().toIso8601String(),
          'statut_plainte': 'En cours',
        },
      );
      return PlainteModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur réponse à la plainte: ${e.message}');
    }
  }

  @override
  Future<List<PlainteModel>> getPlaintesByStatut(String statut) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.plaintesCollectionId,
        queries: [
          Query.equal('statut_plainte', statut),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => PlainteModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des plaintes: ${e.message}');
    }
  }

  // === Méthodes legacy pour compatibilité ===

  @override
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId) async {
    return getPlaintesByProprietaire(ownerId.toString());
  }

  @override
  Future<void> updateComplaintStatus({
    required int plainteId,
    required String newStatus,
  }) async {
    await updatePlainteStatut(plainteId.toString(), newStatus);
  }

  @override
  Future<PlainteModel> createComplaint({
    required int locataireId,
    required String sujet,
    required String description,
    required int bienId,
  }) async {
    // Récupérer le bien pour obtenir le propriétaire
    final bienDoc = await _appwriteService.getDocument(
      collectionId: Environment.biensCollectionId,
      documentId: bienId.toString(),
    );
    final proprietaireId = bienDoc.data['id_proprietaire'] ?? '';

    final plainte = PlainteModel(
      idPlainte: 0,
      idLocataire: locataireId.toString(),
      idBien: bienId.toString(),
      idProprietaireGestionnaire: proprietaireId,
      dateCreation: DateTime.now(),
      sujet: sujet,
      description: description,
      statutPlainte: 'Ouverte',
    );

    return createPlainte(plainte);
  }
}

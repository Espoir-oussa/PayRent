// Fichier : lib/data/repositories/facture_repository_appwrite.dart
// Implémentation du repository des factures utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../config/environment.dart';
import '../../domain/repositories/facture_repository.dart';
import '../models/facture_model.dart';

class FactureRepositoryAppwrite implements FactureRepository {
  final AppwriteService _appwriteService;

  FactureRepositoryAppwrite(this._appwriteService);

  @override
  Future<FactureModel?> getFactureByPaiement(String paiementId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.facturesCollectionId,
        queries: [
          Query.equal('id_paiement', paiementId),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) return null;
      return FactureModel.fromAppwrite(result.documents.first);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération de la facture: ${e.message}');
    }
  }

  @override
  Future<FactureModel> getFactureById(String factureId) async {
    try {
      final doc = await _appwriteService.getDocument(
        collectionId: Environment.facturesCollectionId,
        documentId: factureId,
      );
      return FactureModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération de la facture: ${e.message}');
    }
  }

  @override
  Future<List<FactureModel>> getFacturesByLocataire(String locataireId) async {
    try {
      // D'abord récupérer les contrats du locataire
      final contratsResult = await _appwriteService.listDocuments(
        collectionId: Environment.contratsCollectionId,
        queries: [Query.equal('id_locataire', locataireId)],
      );

      if (contratsResult.documents.isEmpty) return [];

      final contratsIds = contratsResult.documents.map((doc) => doc.$id).toList();

      // Récupérer les paiements de ces contrats
      final paiementsResult = await _appwriteService.listDocuments(
        collectionId: Environment.paiementsCollectionId,
        queries: [Query.equal('id_contrat', contratsIds)],
      );

      if (paiementsResult.documents.isEmpty) return [];

      final paiementsIds = paiementsResult.documents.map((doc) => doc.$id).toList();

      // Récupérer les factures de ces paiements
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.facturesCollectionId,
        queries: [
          Query.equal('id_paiement', paiementsIds),
          Query.orderDesc('date_emission'),
        ],
      );

      return result.documents
          .map((doc) => FactureModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des factures: ${e.message}');
    }
  }

  @override
  Future<FactureModel> createFacture(FactureModel facture) async {
    try {
      final currentUser = await _appwriteService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Générer un numéro de facture unique
      final numeroFacture = 'FAC-${DateTime.now().millisecondsSinceEpoch}';

      final doc = await _appwriteService.createDocument(
        collectionId: Environment.facturesCollectionId,
        data: {
          ...facture.toAppwrite(),
          'numero_facture': numeroFacture,
        },
        permissions: [
          Permission.read(Role.user(currentUser.$id)),
        ],
      );

      return FactureModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur création de la facture: ${e.message}');
    }
  }

  @override
  Future<List<FactureModel>> getFacturesByPeriode(DateTime debut, DateTime fin) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.facturesCollectionId,
        queries: [
          Query.greaterThanEqual('date_emission', debut.toIso8601String()),
          Query.lessThanEqual('date_emission', fin.toIso8601String()),
          Query.orderDesc('date_emission'),
        ],
      );

      return result.documents
          .map((doc) => FactureModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des factures: ${e.message}');
    }
  }

  @override
  Future<String> getFacturePdfUrl(String factureId) async {
    try {
      final facture = await getFactureById(factureId);
      if (facture.cheminFichierPdf == null) {
        throw Exception('Aucun PDF associé à cette facture');
      }

      return _appwriteService.getFileDownloadUrl(
        bucketId: Environment.documentsBucketId,
        fileId: facture.cheminFichierPdf!,
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération du PDF: ${e.message}');
    }
  }

  /// Uploader un PDF de facture
  Future<String> uploadFacturePdf({
    required String factureId,
    required InputFile pdfFile,
  }) async {
    try {
      final file = await _appwriteService.uploadFile(
        bucketId: Environment.documentsBucketId,
        file: pdfFile,
        fileId: 'facture_$factureId',
      );

      // Mettre à jour la facture avec le chemin du fichier
      await _appwriteService.updateDocument(
        collectionId: Environment.facturesCollectionId,
        documentId: factureId,
        data: {'chemin_fichier_pdf': file.$id},
      );

      return file.$id;
    } on AppwriteException catch (e) {
      throw Exception('Erreur upload du PDF: ${e.message}');
    }
  }
}

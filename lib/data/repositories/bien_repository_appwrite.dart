// Fichier : lib/data/repositories/bien_repository_appwrite.dart
// Implémentation du repository des biens utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../config/environment.dart';
import '../../domain/repositories/bien_repository.dart';
import '../models/bien_model.dart';

class BienRepositoryAppwrite implements BienRepository {
  final AppwriteService _appwriteService;

  BienRepositoryAppwrite(this._appwriteService);

  @override
  Future<List<BienModel>> getBiensByProprietaire(String proprietaireId) async {
    try {
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.biensCollectionId,
        queries: [
          Query.equal('id_proprietaire', proprietaireId),
          Query.orderDesc('date_creation'),
        ],
      );

      return result.documents
          .map((doc) => BienModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération des biens: ${e.message}');
    }
  }

  @override
  Future<BienModel> getBienById(String bienId) async {
    try {
      final doc = await _appwriteService.getDocument(
        collectionId: Environment.biensCollectionId,
        documentId: bienId,
      );
      return BienModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur récupération du bien: ${e.message}');
    }
  }

  @override
  Future<BienModel> createBien(BienModel bien) async {
    try {
      // Récupérer l'utilisateur courant pour les permissions
      final currentUser = await _appwriteService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final doc = await _appwriteService.createDocument(
        collectionId: Environment.biensCollectionId,
        data: bien.toAppwrite(),
        permissions: [
          Permission.read(Role.user(currentUser.$id)),
          Permission.update(Role.user(currentUser.$id)),
          Permission.delete(Role.user(currentUser.$id)),
        ],
      );

      return BienModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur création du bien: ${e.message}');
    }
  }

  @override
  Future<BienModel> updateBien(String bienId, BienModel bien) async {
    try {
      final doc = await _appwriteService.updateDocument(
        collectionId: Environment.biensCollectionId,
        documentId: bienId,
        data: bien.toAppwrite(),
      );
      return BienModel.fromAppwrite(doc);
    } on AppwriteException catch (e) {
      throw Exception('Erreur mise à jour du bien: ${e.message}');
    }
  }

  @override
  Future<void> deleteBien(String bienId) async {
    try {
      await _appwriteService.deleteDocument(
        collectionId: Environment.biensCollectionId,
        documentId: bienId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur suppression du bien: ${e.message}');
    }
  }

  @override
  Future<List<BienModel>> searchBiens({
    String? typeBien,
    double? loyerMin,
    double? loyerMax,
    String? adresse,
  }) async {
    try {
      final queries = <String>[];

      if (typeBien != null && typeBien.isNotEmpty) {
        queries.add(Query.equal('type_bien', typeBien));
      }
      if (loyerMin != null) {
        queries.add(Query.greaterThanEqual('loyer_de_base', loyerMin));
      }
      if (loyerMax != null) {
        queries.add(Query.lessThanEqual('loyer_de_base', loyerMax));
      }
      if (adresse != null && adresse.isNotEmpty) {
        queries.add(Query.search('adresse_complete', adresse));
      }

      final result = await _appwriteService.listDocuments(
        collectionId: Environment.biensCollectionId,
        queries: queries.isEmpty ? null : queries,
      );

      return result.documents
          .map((doc) => BienModel.fromAppwrite(doc))
          .toList();
    } on AppwriteException catch (e) {
      throw Exception('Erreur recherche des biens: ${e.message}');
    }
  }

  /// Uploader une image pour un bien
  Future<String> uploadBienImage({
    required String bienId,
    required InputFile imageFile,
  }) async {
    try {
      final file = await _appwriteService.uploadFile(
        bucketId: Environment.imagesBucketId,
        file: imageFile,
        fileId: 'bien_$bienId',
      );

      return _appwriteService.getFilePreviewUrl(
        bucketId: Environment.imagesBucketId,
        fileId: file.$id,
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur upload image: ${e.message}');
    }
  }
}

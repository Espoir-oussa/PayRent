// Fichier : lib/data/repositories/bien_repository_appwrite.dart
// Implémentation du repository des biens utilisant Appwrite

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('🔍 Recherche des biens pour proprietaireId: $proprietaireId');

      // 🔐 AJOUTE CETTE VÉRIFICATION DE SÉCURITÉ
    final currentUser = await _appwriteService.getCurrentUser();
    if (currentUser == null) {
      debugPrint('🚨 Utilisateur non connecté');
      return [];
    }
    
    // Vérifier que l'utilisateur demande bien SES biens
    if (currentUser.$id != proprietaireId) {
      debugPrint('🚨 ALERTE SECURITE: User ${currentUser.$id} tente d\'accéder aux biens de $proprietaireId');
      return []; // Retourne liste vide pour les autres utilisateurs
    }

      // Requête filtrée par proprietaireId
      final result = await _appwriteService.listDocuments(
        collectionId: Environment.biensCollectionId,
        queries: [Query.equal('proprietaireId', proprietaireId)],
      );

      debugPrint('📦 Documents trouvés: ${result.documents.length}');

      final biens = result.documents
          .map((doc) {
            final bien = BienModel.fromAppwrite(doc);
            debugPrint(
              '  - Bien: ${bien.nom}, proprietaireId: ${bien.proprietaireId}',
            );
            return bien;
          })
          .where((bien) => bien.proprietaireId == proprietaireId)
          .toList();

      debugPrint('✅ Biens filtrés: ${biens.length}');
      return biens;
    } on AppwriteException catch (e) {
      debugPrint('❌ Erreur récupération des biens: ${e.message}');
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
    debugPrint('🎯 DEBUT createBien');
    
    // Récupérer l'utilisateur courant
    final currentUser = await _appwriteService.getCurrentUser();
    if (currentUser == null) {
      debugPrint('❌ ERREUR: Utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }

    debugPrint('👤 User ID: ${currentUser.$id}');
    debugPrint('🏠 Bien à créer: ${bien.nom}');

    // 1. Préparer les données
    final Map<String, dynamic> dataToSend = {
      'proprietaireId': currentUser.$id, // FORCER le proprietaireId
      'nom': bien.nom,
      'adresse': bien.adresse,
      'type': bien.type ?? 'appartement',
      'description': bien.description ?? '',
      'loyerMensuel': bien.loyerMensuel,
      'charges': bien.charges ?? 0.0,
      'caution': bien.caution ?? 0.0,
      'statut': bien.statut ?? 'disponible',
      'photosUrls': bien.photosUrls?.join(',') ?? '',
      'equipements': bien.equipements?.join(',') ?? '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    debugPrint('📦 Données à envoyer:');
    dataToSend.forEach((key, value) {
      debugPrint('   $key: $value');
    });

    // 2. ESSAYER SANS PERMISSIONS
    debugPrint('🔐 Tentative de création SANS permissions...');
    
    try {
      final doc = await _appwriteService.createDocument(
        collectionId: Environment.biensCollectionId,
        data: dataToSend,
        permissions: null, // PAS de permissions
      );

      debugPrint('✅ SUCCÈS! Document créé: ${doc.$id}');
      
      final createdBien = BienModel.fromAppwrite(doc);
      debugPrint('🏠 Bien créé: ${createdBien.nom}');
      debugPrint('   proprietaireId: ${createdBien.proprietaireId}');
      
      return createdBien;
      
    } on AppwriteException catch (e) {
      debugPrint('❌ ERREUR Appwrite: ${e.message}');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Type: ${e.type}');
      
      // Si erreur de permissions, essayer avec permissions vides
      if (e.message?.contains('permission') == true) {
        debugPrint('🔄 Essai avec permissions vides...');
        
        final doc = await _appwriteService.createDocument(
          collectionId: Environment.biensCollectionId,
          data: dataToSend,
          permissions: <String>[], // Liste vide
        );
        
        debugPrint('✅ Créé avec permissions vides: ${doc.$id}');
        return BienModel.fromAppwrite(doc);
      }
      
      rethrow;
    }
    
  } catch (e) {
    debugPrint('💥 ERREUR FATALE dans createBien: $e');
    debugPrint('💥 StackTrace: ${e.toString()}');
    rethrow;
  }
}

  @override
Future<BienModel> updateBien(String bienId, BienModel bien) async {
  try {
    debugPrint('🎯 DEBUT updateBien pour ID: $bienId');
    debugPrint('🏠 Bien: ${bien.nom}');
    
    final currentUser = await _appwriteService.getCurrentUser();
    if (currentUser != null) {
      debugPrint('👤 User actuel: ${currentUser.$id}');
      debugPrint('👤 Proprietaire du bien: ${bien.proprietaireId}');
    }
    
    // Ajouter updatedAt
    final dataToSend = Map<String, dynamic>.from(bien.toAppwrite())
      ..['updatedAt'] = DateTime.now().toIso8601String();
    
    debugPrint('📦 Données de mise à jour: $dataToSend');
    
    final doc = await _appwriteService.updateDocument(
      collectionId: Environment.biensCollectionId,
      documentId: bienId,
      data: dataToSend,
    );
    
    debugPrint('✅ Bien mis à jour: ${doc.$id}');
    return BienModel.fromAppwrite(doc);
    
  } on AppwriteException catch (e) {
    debugPrint('❌ Erreur mise à jour: ${e.message}');
    debugPrint('   Code: ${e.code}');
    debugPrint('   Type: ${e.type}');
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
        queries.add(Query.equal('type', typeBien));
      }
      if (loyerMin != null) {
        queries.add(Query.greaterThanEqual('loyerMensuel', loyerMin));
      }
      if (loyerMax != null) {
        queries.add(Query.lessThanEqual('loyerMensuel', loyerMax));
      }
      if (adresse != null && adresse.isNotEmpty) {
        queries.add(Query.search('adresse', adresse));
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

// Service centralisé pour l'upload d'images vers Appwrite Storage
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../../config/environment.dart';

class ImageUploadService {
  final AppwriteService _appwriteService;
  late final Storage _storage;

  ImageUploadService(this._appwriteService) {
    _storage = Storage(_appwriteService.client);
  }

  /// Upload une image et retourne l'URL publique
  /// [filePath] - Chemin local du fichier
  /// [folder] - Dossier de destination (ex: 'profiles', 'biens')
  /// [userId] - ID de l'utilisateur pour les permissions
  Future<String> uploadImage({
    required String filePath,
    required String folder,
    String? userId,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${folder}_${userId ?? 'file'}_$timestamp.jpg';

      // Créer le fichier avec les permissions appropriées
      final file = await _storage.createFile(
        bucketId: Environment.imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: filePath,
          filename: filename,
        ),
        permissions: userId != null
            ? [
                Permission.read(Role.any()), // Lecture publique pour afficher l'image
                Permission.update(Role.user(userId)),
                Permission.delete(Role.user(userId)),
              ]
            : [
                Permission.read(Role.any()),
              ],
      );

      // Construire et retourner l'URL publique
      return getFileUrl(file.$id);
    } on AppwriteException catch (e) {
      throw Exception('Erreur upload image: ${e.message}');
    }
  }

  /// Supprime une image du storage
  Future<void> deleteImage(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: Environment.imagesBucketId,
        fileId: fileId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Erreur suppression image: ${e.message}');
    }
  }

  /// Extrait l'ID du fichier depuis une URL Appwrite
  String? extractFileIdFromUrl(String url) {
    final regex = RegExp(r'/files/([^/]+)/');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Construit l'URL publique d'un fichier
  String getFileUrl(String fileId) {
    return '${Environment.appwritePublicEndpoint}/storage/buckets/${Environment.imagesBucketId}/files/$fileId/view?project=${Environment.appwriteProjectId}';
  }

  /// Construit l'URL de preview d'un fichier (avec redimensionnement)
  String getFilePreviewUrl(String fileId, {int? width, int? height}) {
    var url = '${Environment.appwritePublicEndpoint}/storage/buckets/${Environment.imagesBucketId}/files/$fileId/preview?project=${Environment.appwriteProjectId}';
    if (width != null) url += '&width=$width';
    if (height != null) url += '&height=$height';
    return url;
  }
}

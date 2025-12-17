// Fichier : lib/core/services/appwrite_service.dart
// Service centralisé pour la gestion d'Appwrite

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../config/environment.dart';

/// Service singleton pour gérer les connexions Appwrite
class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;
  late final Realtime _realtime;

  bool _isInitialized = false;

  /// Initialise le client Appwrite
  /// Doit être appelé au démarrage de l'application (dans main.dart)
  void init() {
    if (_isInitialized) return;

    _client = Client()
      ..setEndpoint(Environment.appwritePublicEndpoint)
      ..setProject(Environment.appwriteProjectId)
      ..setSelfSigned(status: true); // À désactiver en production

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);

    _isInitialized = true;
  }

  // ============================================================
  // GETTERS POUR ACCÉDER AUX SERVICES APPWRITE
  // ============================================================

  Client get client {
    _checkInitialized();
    return _client;
  }

  Account get account {
    _checkInitialized();
    return _account;
  }

  Databases get databases {
    _checkInitialized();
    return _databases;
  }

  Storage get storage {
    _checkInitialized();
    return _storage;
  }

  Realtime get realtime {
    _checkInitialized();
    return _realtime;
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'AppwriteService non initialisé. Appelez AppwriteService().init() dans main.dart',
      );
    }
  }

  // ============================================================
  // MÉTHODES D'AUTHENTIFICATION
  // ============================================================

  /// Créer un compte utilisateur avec email et mot de passe
  Future<models.User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  /// Connexion avec email et mot de passe
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    return await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  /// Déconnexion de la session actuelle
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }

  /// Mettre à jour le mot de passe de l'utilisateur connecté
  Future<void> updatePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    await _account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  /// Demander un email de récupération de mot de passe (Appwrite)
  Future<void> createRecovery({
    required String email,
    required String url,
  }) async {
    await _account.createRecovery(
      email: email,
      url: url,
    );
  }

  /// Supprimer définitivement le compte utilisateur (Auth)
  /// Attention: Cette action est irréversible
  Future<void> deleteCurrentAccount() async {
    try {
      // Utiliser updateStatus pour désactiver le compte
      // Note: La suppression complète nécessite les droits admin côté serveur
      // Pour une vraie suppression, il faudrait une Cloud Function Appwrite
      await _account.updateStatus();
    } catch (e) {
      // Si updateStatus échoue, on continue (le compte sera au moins déconnecté)
      rethrow;
    }
  }

  /// Récupérer l'utilisateur actuellement connecté
  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      await _account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // MÉTHODES POUR LA BASE DE DONNÉES
  // ============================================================

  /// Créer un document dans une collection
  Future<models.Document> createDocument({
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
    List<String>? permissions,
  }) async {
    return await _databases.createDocument(
      databaseId: Environment.databaseId,
      collectionId: collectionId,
      documentId: documentId ?? ID.unique(),
      data: data,
      permissions: permissions,
    );
  }

  /// Récupérer un document par son ID
  Future<models.Document> getDocument({
    required String collectionId,
    required String documentId,
  }) async {
    return await _databases.getDocument(
      databaseId: Environment.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  /// Lister les documents d'une collection avec des filtres optionnels
  Future<models.DocumentList> listDocuments({
    required String collectionId,
    List<String>? queries,
  }) async {
    return await _databases.listDocuments(
      databaseId: Environment.databaseId,
      collectionId: collectionId,
      queries: queries,
    );
  }

  /// Mettre à jour un document
  Future<models.Document> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return await _databases.updateDocument(
      databaseId: Environment.databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  /// Supprimer un document
  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    await _databases.deleteDocument(
      databaseId: Environment.databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  // ============================================================
  // MÉTHODES POUR LE STOCKAGE (IMAGES, DOCUMENTS)
  // ============================================================

  /// Normalise une liste de permissions (Permission objects ou String)
  List<String>? normalizePermissions(List<dynamic>? permissions) {
    if (permissions == null) return null;
    return permissions.map((p) {
      final s = p is String ? p : p.toString();
      // Supprimer les espaces après ':' et autour des virgules, puis trim
      return s.replaceAllMapped(RegExp(r':\s+'), (m) => ':').replaceAll(RegExp(r'\s*,\s*'), ',').trim();
    }).toList();
  }

  /// Uploader un fichier
  Future<models.File> uploadFile({
    required String bucketId,
    required InputFile file,
    String? fileId,
    List<dynamic>? permissions,
  }) async {
    final permsToSend = normalizePermissions(permissions);
    if (permsToSend != null) print('🔐 uploadFile -> permissions: $permsToSend');

    return await _storage.createFile(
      bucketId: bucketId,
      fileId: fileId ?? ID.unique(),
      file: file,
      permissions: permsToSend,
    );
  }

  /// Récupérer l'URL de prévisualisation d'un fichier
  String getFilePreviewUrl({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
  }) {
    // Construire l'URL manuellement car getFilePreview retourne des bytes
    String url = '${Environment.appwritePublicEndpoint}/storage/buckets/$bucketId/files/$fileId/preview?project=${Environment.appwriteProjectId}';
    if (width != null) url += '&width=$width';
    if (height != null) url += '&height=$height';
    return url;
  }

  /// Récupérer l'URL de téléchargement d'un fichier
  String getFileDownloadUrl({
    required String bucketId,
    required String fileId,
  }) {
    return '${Environment.appwritePublicEndpoint}/storage/buckets/$bucketId/files/$fileId/download?project=${Environment.appwriteProjectId}';
  }

  /// Supprimer un fichier
  Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    await _storage.deleteFile(
      bucketId: bucketId,
      fileId: fileId,
    );
  }

  // ============================================================
  // MÉTHODES REALTIME (TEMPS RÉEL)
  // ============================================================

  /// S'abonner aux changements d'une collection
  RealtimeSubscription subscribeToCollection(String collectionId) {
    return _realtime.subscribe([
      'databases.${Environment.databaseId}.collections.$collectionId.documents'
    ]);
  }
}

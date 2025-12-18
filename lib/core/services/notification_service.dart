import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../config/environment.dart';

class NotificationService {
  final Client _client;

  NotificationService(this._client);

  Future<void> createNotificationForUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final databases = Databases(_client);
    await databases.createDocument(
      databaseId: Environment.databaseId,
      collectionId: Environment.notificationsCollectionId,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> unreadCountForUser(String userId) async {
    final databases = Databases(_client);
    final res = await databases.listDocuments(
      databaseId: Environment.databaseId,
      collectionId: Environment.notificationsCollectionId,
      queries: [Query.equal('userId', userId), Query.equal('isRead', false)],
    );
    return res.documents.length;
  }

  /// Récupérer la liste des notifications pour un utilisateur
  Future<List<models.Document>> getNotificationsForUser(String userId, {int limit = 50}) async {
    final databases = Databases(_client);
    final res = await databases.listDocuments(
      databaseId: Environment.databaseId,
      collectionId: Environment.notificationsCollectionId,
      queries: [Query.equal('userId', userId), Query.orderDesc('createdAt'), Query.limit(limit)],
    );
    return res.documents;
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    final databases = Databases(_client);
    await databases.updateDocument(
      databaseId: Environment.databaseId,
      collectionId: Environment.notificationsCollectionId,
      documentId: notificationId,
      data: {'isRead': true},
    );
  }
}

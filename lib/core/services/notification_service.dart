import 'package:appwrite/appwrite.dart';
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
}

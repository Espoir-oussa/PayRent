import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;
import '../../../core/di/providers.dart';


class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _isLoading = false;
  List<models.Document> _notifications = [];

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;
      final notifService = ref.read(notificationServiceProvider);
      final list = await notifService.getNotificationsForUser(userId as String);
      if (mounted) setState(() => _notifications = list);
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(String id) async {
    try {
      final notifService = ref.read(notificationServiceProvider);
      await notifService.markAsRead(id);
      ref.invalidate(unreadNotificationsCountProvider);
      await _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    // Écouter le provider realtime pour rafraîchir automatiquement
    ref.listen(notificationsRealtimeProvider, (prev, sub) async {
      await _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Aucune notification'))
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = _notifications[index];
                    final data = Map<String, dynamic>.from(doc.data);
                    final isRead = (data['isRead'] == true || data['isRead'] == 'true');
                    final title = data['title'] ?? 'Notification';
                    final body = data['body'] ?? '';
                    return ListTile(
                      title: Text(title, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(body),
                      trailing: isRead
                          ? null
                          : TextButton(
                              onPressed: () => _markRead(doc.$id),
                              child: const Text('Marquer lu'),
                            ),
                      onTap: () async {
                        if (!isRead) await _markRead(doc.$id);
                        // TODO: gérer l'action (data) : navigation vers bien, etc.
                      },
                    );
                  },
                ),
    );
  }
}

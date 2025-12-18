import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../shared/pages/notifications_screen.dart';

class SharedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String currentRole; // 'owner' ou 'tenant'
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogoutPressed;

  const SharedAppBar({
    super.key,
    required this.currentRole,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.onLogoutPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  Future<void> _openNotificationsPage(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    
    // ✅ CORRECTION : Invalider les providers pour rafraîchir les compteurs
    ref.invalidate(pendingInvitationsProvider);
    ref.invalidate(totalNotificationsCountProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ CORRECTION : Démarrer l'écoute realtime au bon moment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invitationsRealtimeProvider);
    });

    return AppBar(
      backgroundColor: AppColors.accentRed,
      foregroundColor: AppColors.textLight,
      automaticallyImplyLeading: false,
      elevation: 4,
      toolbarHeight: 80,
      title: SizedBox(
        height: 100,
        child: Row(
          children: [
            Image.asset(
              'assets/images/payrent_blanc.png',
              height: 100,
              color: AppColors.textLight,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
      centerTitle: false,
      actions: [
        // Bouton Notifications avec badge
        Consumer(
          builder: (context, ref, child) {
            // ✅ CORRECTION : Utiliser un FutureProvider plus fiable
            final totalNotifsAsync = ref.watch(totalNotificationsCountProvider);
            
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 28),
                  onPressed: () => _openNotificationsPage(context, ref),
                  padding: const EdgeInsets.all(8),
                ),
                Positioned(
                  right: 6,
                  top: 10,
                  child: totalNotifsAsync.when(
                    data: (count) => count > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: const TextStyle(
                                color: AppColors.accentRed,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
        
        // Menu profil
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle_outlined, size: 32),
          tooltip: 'Menu du profil',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          offset: const Offset(0, 50),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                if (onProfilePressed != null) {
                  onProfilePressed!();
                }
                break;
              case 'deconnexion':
                if (onLogoutPressed != null) {
                  onLogoutPressed!();
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: const [
                  Icon(Icons.person_outline, color: AppColors.primaryDark),
                  SizedBox(width: 12),
                  Text('Mon profil'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'deconnexion',
              child: Row(
                children: [
                  Icon(Icons.logout_outlined, color: AppColors.accentRed),
                  const SizedBox(width: 12),
                  const Text(
                    'Déconnexion',
                    style: TextStyle(color: AppColors.accentRed),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
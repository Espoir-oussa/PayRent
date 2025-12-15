import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';

/// AppBar partagée qui s'adapte au rôle de l'utilisateur
/// Peut être utilisée à la fois par propriétaire et locataire
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadNotificationsCountProvider);

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
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 28),
              onPressed: onNotificationsPressed ?? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications - À implémenter'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              },
              padding: const EdgeInsets.all(8),
            ),
            Positioned(
              right: 6,
              top: 10,
              child: unreadAsync.when(
                data: (count) => count > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: AppColors.accentRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
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
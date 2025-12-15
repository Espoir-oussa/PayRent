// ===============================
// 🏠 Écran : Accueil Propriétaire
//
// Ce fichier définit l'interface utilisateur principale pour le propriétaire.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : Tableau de bord du propriétaire
// Utilisé par : Propriétaires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import 'bien_management_screen.dart';
import 'complaint_tracking_screen.dart';
import 'invoicing_screen.dart';
import 'payment_history_screen.dart';
import 'profile_screen.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/appwrite_service.dart';
import '../widgets/owner_scaffold.dart';

class HomeOwnerScreen extends ConsumerStatefulWidget {
  const HomeOwnerScreen({super.key});

  @override
  ConsumerState<HomeOwnerScreen> createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends ConsumerState<HomeOwnerScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BienManagementScreen(),
    const ComplaintTrackingScreen(),
    const PaymentHistoryScreen(),
    const InvoicingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: (i) => setState(() => _currentIndex = i),
      body: _screens[_currentIndex],
    );
  }

  // Cette méthode peut être supprimée si OwnerScaffold gère déjà le menu
  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
      case 'deconnexion':
        _showLogoutConfirmationDialog(context);
        break;
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Déconnexion',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.primaryDark),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Déconnexion Appwrite
      await AppwriteService().logout();

      // Reset du state local
      ref.read(ownerLoginControllerProvider.notifier).resetState();

      // Redirection vers la page de login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login_owner',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
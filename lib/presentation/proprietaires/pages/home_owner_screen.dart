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
  
  final List<IconData> _bottomIcons = [
    Icons.home_work_outlined,
    Icons.report_problem_outlined,
    Icons.payments_outlined,
    Icons.receipt_long_outlined,
  ];
  
  final List<String> _bottomLabels = [
    'Biens',
    'Plaintes',
    'Paiements',
    'Factures',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.textLight,
        elevation: 4,
        toolbarHeight: 80,
        title: SizedBox(
          height: 100,
          child: Image.asset(
            'assets/images/payrent_blanc.png',
            height: 60,
            color: AppColors.textLight,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                onPressed: _handleNotifications,
                padding: const EdgeInsets.all(8),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
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
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: const Row(
                  children: [
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
      ),
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

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
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(ownerLoginControllerProvider.notifier).resetState();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentRed,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'MuseoModerno',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'MuseoModerno',
        ),
        items: List.generate(_bottomIcons.length, (index) {
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                _bottomIcons[index],
                size: 26,
              ),
            ),
            label: _bottomLabels[index],
          );
        }),
      ),
    );
  }

  void _handleNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications - À implémenter'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }
}
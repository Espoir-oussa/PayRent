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

class HomeOwnerScreen extends ConsumerStatefulWidget {
  const HomeOwnerScreen({super.key});

  @override
  ConsumerState<HomeOwnerScreen> createState() => _HomeOwnerScreenState();
}

class _HomeOwnerScreenState extends ConsumerState<HomeOwnerScreen> {
  int _currentIndex = 0;
  
  // Liste des écrans pour chaque tab (sans accueil)
  final List<Widget> _screens = [
    const BienManagementScreen(),      // Tab 0: Biens
    const ComplaintTrackingScreen(),   // Tab 1: Plaintes
    const PaymentHistoryScreen(),      // Tab 2: Paiements
    const InvoicingScreen(),           // Tab 3: Factures
  ];

  // Icônes pour la Bottom Navigation
  final List<IconData> _bottomIcons = [
    Icons.home_work_outlined,     // Biens
    Icons.report_problem_outlined, // Plaintes
    Icons.payments_outlined,       // Paiements
    Icons.receipt_long_outlined,   // Factures
  ];

  // Labels pour la Bottom Navigation
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
        toolbarHeight: 80, // AppBar plus grande
        title: SizedBox(
          height: 100, // Hauteur cohérente pour le logo
          child: Image.asset(
            'assets/images/payrent_blanc.png',
            height: 100, // Même valeur que le parent
            color: AppColors.textLight,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: false,
        actions: [
          // Container pour espacer les icônes
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                // Notification icon avec badge
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
                // Profile icon plus grand
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined, size: 32),
                  onPressed: _handleProfile,
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70, // BottomNavigationBar plus haute
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
          fontSize: 13, // Texte légèrement plus grand
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
                size: 26, // Icônes plus grandes
              ),
            ),
            label: _bottomLabels[index],
          );
        }),
      ),
    );
  }

  void _handleNotifications() {
    // TODO: Naviguer vers les notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications - À implémenter'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _handleProfile() {
    // TODO: Naviguer vers le profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil - À implémenter'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }
}
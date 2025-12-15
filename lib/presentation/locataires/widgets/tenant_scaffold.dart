import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../shared/widgets/role_toggle.dart';

class TenantScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onLogoutPressed;
  final bool showRoleToggle;

  const TenantScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onIndexChanged,
    this.onNotificationsPressed,
    this.onLogoutPressed,
    this.showRoleToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.textLight,
        automaticallyImplyLeading: false,
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
                onPressed: onNotificationsPressed ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications - À implémenter')),
                  );
                },
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
                  constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined, size: 32),
            tooltip: 'Menu du profil',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            offset: const Offset(0, 50),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  // Switch to profile tab
                  onIndexChanged(3);
                  break;
                case 'deconnexion':
                  if (onLogoutPressed != null) onLogoutPressed!();
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
                    const Text('Déconnexion', style: TextStyle(color: AppColors.accentRed)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (showRoleToggle) ...[
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: RoleToggle(),
              ),
            ],
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        currentIndex: currentIndex,
        onTap: onIndexChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentRed,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 0),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Paiements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label: 'Plaintes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
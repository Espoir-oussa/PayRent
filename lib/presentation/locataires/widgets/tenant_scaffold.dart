import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/colors.dart';
import '../../shared/widgets/role_toggle.dart';
import '../../shared/widgets/shared_app_bar.dart';

class TenantScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogoutPressed;

  const TenantScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onIndexChanged,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        currentRole: 'tenant',
        onNotificationsPressed: onNotificationsPressed,
        onProfilePressed: onProfilePressed,
        onLogoutPressed: onLogoutPressed,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: RoleToggle(),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final icons = [
      Icons.home_outlined,
      Icons.payment_outlined,
      Icons.report_problem_outlined,
      Icons.person_outlined,
    ];

    final activeIcons = [
      Icons.home,
      Icons.payment,
      Icons.report_problem,
      Icons.person,
    ];

    final labels = ['Accueil', 'Paiements', 'Plaintes', 'Profil'];

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
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 0,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: List.generate(icons.length, (index) {
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Icon(
                currentIndex == index ? activeIcons[index] : icons[index],
                size: 26,
              ),
            ),
            label: labels[index],
          );
        }),
      ),
    );
  }
}
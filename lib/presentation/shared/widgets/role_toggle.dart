import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../proprietaires/pages/home_owner_screen.dart';
import '../../locataires/pages/home_tenant_screen.dart';
import '../../../config/colors.dart';

class RoleToggle extends ConsumerWidget {
  const RoleToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(selectedRoleProvider);
    final notifier = ref.read(selectedRoleProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  notifier.select('proprietaire');
                  // Naviguer immédiatement vers l'accueil propriétaire
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeOwnerScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: role == 'proprietaire' ? AppColors.accentRed : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: role == 'proprietaire' ? AppColors.accentRed : Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text('Propriétaire',
                          style: TextStyle(
                            fontSize: 14,
                            color: role == 'proprietaire' ? Colors.white : Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  notifier.select('locataire');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeTenantScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: role == 'locataire' ? AppColors.accentRed : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: role == 'locataire' ? AppColors.accentRed : Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text('Locataire',
                          style: TextStyle(
                            fontSize: 14,
                            color: role == 'locataire' ? Colors.white : Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

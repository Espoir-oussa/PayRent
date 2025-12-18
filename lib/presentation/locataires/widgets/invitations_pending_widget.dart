// lib/presentation/locataires/widgets/invitations_pending_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/invitation_model.dart';
import '../../shared/pages/notifications_screen.dart';

class InvitationsPendingWidget extends ConsumerWidget {
  const InvitationsPendingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingInvitationsAsync = ref.watch(pendingInvitationsProvider);
    
    return pendingInvitationsAsync.when(
      data: (invitations) {
        if (invitations.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final amberColor = Colors.amber;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: amberColor.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: amberColor.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: amberColor.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: amberColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${invitations.length} invitation(s) en attente',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: amberColor.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cliquez pour voir et répondre',
                          style: TextStyle(
                            fontSize: 14,
                            color: amberColor.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: amberColor.shade700,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(width: 12),
            Text(
              'Chargement des invitations...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      error: (error, _) {
        final redColor = Colors.red;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: redColor.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: redColor.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: redColor.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erreur chargement invitations',
                  style: TextStyle(color: redColor.shade800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
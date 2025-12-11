// Fichier : lib/presentation/shared/widgets/invitation_list_widget.dart
// Widget pour afficher la liste des invitations d'un bien

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/colors.dart';
import '../../../data/models/invitation_model.dart';

class InvitationListWidget extends StatelessWidget {
  final List<InvitationModel> invitations;
  final VoidCallback? onRefresh;
  final Function(InvitationModel)? onCancel;

  const InvitationListWidget({
    super.key,
    required this.invitations,
    this.onRefresh,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.mail_outline, color: AppColors.primaryDark, size: 20),
              const SizedBox(width: 8),
              Text(
                'Invitations envoyées',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: onRefresh,
                  tooltip: 'Actualiser',
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invitations.length,
          itemBuilder: (context, index) {
            final invitation = invitations[index];
            return _InvitationCard(
              invitation: invitation,
              onCancel: onCancel,
            );
          },
        ),
      ],
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final Function(InvitationModel)? onCancel;

  const _InvitationCard({
    required this.invitation,
    this.onCancel,
  });

  Color _getStatusColor() {
    switch (invitation.statut) {
      case InvitationStatus.pending:
        return Colors.orange;
      case InvitationStatus.accepted:
        return Colors.green;
      case InvitationStatus.rejected:
        return Colors.red;
      case InvitationStatus.expired:
      case InvitationStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (invitation.statut) {
      case InvitationStatus.pending:
        return Icons.hourglass_empty;
      case InvitationStatus.accepted:
        return Icons.check_circle;
      case InvitationStatus.rejected:
        return Icons.cancel;
      case InvitationStatus.expired:
        return Icons.schedule;
      case InvitationStatus.cancelled:
        return Icons.block;
    }
  }

  String _getStatusText() {
    switch (invitation.statut) {
      case InvitationStatus.pending:
        return 'En attente';
      case InvitationStatus.accepted:
        return 'Acceptée';
      case InvitationStatus.rejected:
        return 'Refusée';
      case InvitationStatus.expired:
        return 'Expirée';
      case InvitationStatus.cancelled:
        return 'Annulée';
    }
  }

  String _getNomComplet() {
    final prenom = invitation.prenomLocataire ?? '';
    final nom = invitation.nomLocataire ?? '';
    return '$prenom $nom'.trim();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isExpired = invitation.isExpired && invitation.statut == InvitationStatus.pending;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.grey.shade300 : statusColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom ou email
                  Text(
                    _getNomComplet().isNotEmpty
                        ? _getNomComplet()
                        : invitation.emailLocataire,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Email (si nom présent)
                  if (_getNomComplet().isNotEmpty)
                    Text(
                      invitation.emailLocataire,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // Date et statut
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.grey.shade100 : statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isExpired ? 'Expirée' : _getStatusText(),
                          style: TextStyle(
                            color: isExpired ? Colors.grey : statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Envoyée le ${_formatDate(invitation.dateCreation)}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            if (invitation.statut == InvitationStatus.pending && !isExpired)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'copy') {
                    final link = 'payrent://accept-invitation?token=${invitation.token}';
                    Clipboard.setData(ClipboardData(text: link));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lien copié !'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (value == 'cancel' && onCancel != null) {
                    onCancel!(invitation);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 12),
                        Text('Copier le lien'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Annuler', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

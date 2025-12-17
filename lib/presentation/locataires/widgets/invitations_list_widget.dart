import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';

class InvitationsListWidget extends StatelessWidget {
  final List<InvitationModel> invitations;
  final Future<void> Function(InvitationModel) onAccept;
  final Future<void> Function(InvitationModel) onReject;

  const InvitationsListWidget({
    Key? key,
    required this.invitations,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invitations en attente', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final inv in invitations) ...[
              ListTile(
                title: Text(inv.bienNom),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (inv.proprietaireNom != null && inv.proprietaireNom!.isNotEmpty)
                      Text('Propriétaire: ${inv.proprietaireNom}'),
                    if (inv.message != null && inv.message!.isNotEmpty)
                      Text('Message: ${inv.message}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    Text('Envoyée le ${inv.dateCreation.toLocal().toIso8601String().split('T').first}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => onReject(inv),
                      child: const Text('Refuser', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => onAccept(inv),
                      child: const Text('Accepter'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

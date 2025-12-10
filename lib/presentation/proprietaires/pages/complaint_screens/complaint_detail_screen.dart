// ===============================
// 📄 Écran : Détails d'une plainte
//
// Ce fichier définit l'interface pour afficher les détails d'une plainte
// et permettre au propriétaire d'y répondre (accepter/rejeter).
//
// Dossier : lib/presentation/proprietaires/pages/complaint_screens/
// Rôle : UI pour détails et réponse aux plaintes
// Utilisé par : ComplaintTrackingScreen
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/colors.dart';
import '../../../../data/models/plainte_model.dart';
import '../../../../core/di/providers.dart';
import 'package:intl/intl.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final PlainteModel complaint;
  final int ownerId;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
    required this.ownerId,
  });

  @override
  ConsumerState<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  final _responseController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1. Ouverte':
        return AppColors.accentRed;
      case '2. Réception':
        return AppColors.primaryDark;
      case '3. En Cours de Résolution':
        return AppColors.accentRed.withOpacity(0.75);
      case '4. Résolue':
        return AppColors.primaryDark.withOpacity(0.7);
      case '5. Fermée':
        return AppColors.primaryDark.withOpacity(0.45);
      default:
        return AppColors.primaryDark.withOpacity(0.35);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '1. Ouverte':
        return Icons.error_outline;
      case '2. Réception':
        return Icons.check_circle_outline;
      case '3. En Cours de Résolution':
        return Icons.settings;
      case '4. Résolue':
        return Icons.done_all;
      case '5. Fermée':
        return Icons.close;
      default:
        return Icons.info_outline;
    }
  }

  String? _getDecisionLabel(String status) {
    if (status.startsWith('4')) return 'Acceptée';
    if (status.startsWith('5')) return 'Rejetée';
    return null;
  }

  Future<void> _updateStatus(String newStatus) async {
    final controller = ref.read(complaintTrackingControllerProvider.notifier);

    try {
      await controller.updateComplaintStatus(
        plainteId: widget.complaint.idPlainte,
        newStatus: newStatus,
        ownerId: widget.ownerId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour : $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retourner avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionnez le nouveau statut :'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: '2. Réception', child: Text('Réception')),
                DropdownMenuItem(
                    value: '3. En Cours de Résolution',
                    child: Text('En Cours de Résolution')),
                DropdownMenuItem(value: '4. Résolue', child: Text('Résolue')),
                DropdownMenuItem(value: '5. Fermée', child: Text('Fermée')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _selectedStatus == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    _updateStatus(_selectedStatus!);
                  },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintTrackingControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final decisionLabel = _getDecisionLabel(widget.complaint.statutPlainte);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Détails de la plainte'),
        elevation: 0,
      ),
      body: state.isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec statut
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                        widget.complaint.statutPlainte)
                                    .withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getStatusIcon(widget.complaint.statutPlainte),
                                color: _getStatusColor(
                                    widget.complaint.statutPlainte),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.complaint.statutPlainte,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Plainte #${widget.complaint.idPlainte}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (decisionLabel != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: decisionLabel == 'Rejetée'
                                            ? AppColors.accentRed
                                                .withOpacity(0.2)
                                            : Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        decisionLabel,
                                        style: TextStyle(
                                          color: decisionLabel == 'Rejetée'
                                              ? AppColors.accentRed
                                              : Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dateFormat.format(widget.complaint.dateCreation),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sujet
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.subject,
                                color: AppColors.primaryDark, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Sujet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.complaint.sujet,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description,
                                color: AppColors.primaryDark, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.complaint.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.primaryDark.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informations supplémentaires
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppColors.primaryDark, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Informations',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            'Locataire', 'ID: ${widget.complaint.idLocataire}'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Bien', 'ID: ${widget.complaint.idBien}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showStatusUpdateDialog,
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier le statut'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus('4. Résolue'),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Accepter'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus('5. Fermée'),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Rejeter'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primaryDark.withOpacity(0.65),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

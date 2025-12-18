// ===============================
// 📝 Écran : Suivi des Plaintes (Propriétaire)
//
// Ce fichier définit l'interface utilisateur pour l'affichage et la mise à jour du statut des plaintes.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : UI pour suivi et gestion des plaintes
// Utilisé par : Propriétaires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/plainte_model.dart';

class ComplaintTrackingScreen extends ConsumerStatefulWidget {
  const ComplaintTrackingScreen({super.key});

  @override
  ConsumerState<ComplaintTrackingScreen> createState() =>
      _ComplaintTrackingScreenState();
}

class _ComplaintTrackingScreenState
    extends ConsumerState<ComplaintTrackingScreen> {
  String _selectedFilter = 'Toutes';
  final List<String> _filters = [
    'Toutes',
    'Ouverte',
    'En cours',
    'Resolue',
    'Fermee'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Suivi des Plaintes'),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppColors.primaryDark,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Liste des plaintes
          Expanded(
            child: FutureBuilder<List<PlainteModel>>(
              future: _loadComplaints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Erreur: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final allComplaints = snapshot.data ?? [];
                final filteredComplaints = _selectedFilter == 'Toutes'
                    ? allComplaints
                    : allComplaints
                        .where((c) => c.statutPlainte == _selectedFilter)
                        .toList();

                if (filteredComplaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'Toutes'
                              ? 'Aucune plainte reçue'
                              : 'Aucune plainte "$_selectedFilter"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    return _buildComplaintCard(filteredComplaints[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<PlainteModel>> _loadComplaints() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final user = await appwriteService.getCurrentUser();
      if (user != null) {
        final plainteRepository = ref.read(plainteRepositoryProvider);
        return await plainteRepository.getPlaintesByProprietaire(user.$id);
      }
      return [];
    } catch (e) {
      print('Erreur lors du chargement des plaintes: $e');
      return [];
    }
  }

  Widget _buildComplaintCard(PlainteModel complaint) {
    final statusColor = _getStatusColor(complaint.statutPlainte);
    final statusIcon = _getStatusIcon(complaint.statutPlainte);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showComplaintDetail(complaint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.sujet,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Locataire: ${complaint.idLocataire.substring(0, 8)}...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      complaint.statutPlainte,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(complaint.dateCreation),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetail(PlainteModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  complaint.sujet,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Date', _formatDate(complaint.dateCreation)),
                _buildDetailRow('Locataire', complaint.idLocataire),
                _buildDetailRow('Bien', 'ID ${complaint.idBien}'),
                _buildDetailRow('Statut', complaint.statutPlainte),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(complaint.description),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Changer le statut',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Ouverte', 'En cours', 'Resolue', 'Fermee']
                      .map((status) => _buildStatusChip(complaint, status))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PlainteModel complaint, String status) {
    final isCurrentStatus = complaint.statutPlainte == status;
    final color = _getStatusColor(status);

    return ActionChip(
      label: Text(status),
      backgroundColor:
          isCurrentStatus ? color.withOpacity(0.2) : Colors.grey[200],
      side: BorderSide(
        color: isCurrentStatus ? color : Colors.grey[300]!,
        width: isCurrentStatus ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isCurrentStatus ? color : Colors.black87,
        fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
      ),
      onPressed: isCurrentStatus
          ? null
          : () async {
              await _updateComplaintStatus(complaint, status);
            },
    );
  }

  Future<void> _updateComplaintStatus(
      PlainteModel complaint, String newStatus) async {
    try {
      final updateUseCase = ref.read(updateComplaintStatusUseCaseProvider);
      await updateUseCase(
        plainteId: complaint.idPlainte,
        newStatus: newStatus,
      );

      if (mounted) {
        Navigator.pop(context);
        setState(() {}); // Recharge les données
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut de la plainte mis à jour'),
            backgroundColor: Colors.green,
          ),
        );
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ouverte':
        return Colors.orange;
      case 'en cours':
      case 'en_cours':
        return Colors.blue;
      case 'resolue':
      case 'résolue':
        return Colors.green;
      case 'fermee':
      case 'fermée':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ouverte':
        return Icons.error_outline;
      case 'en cours':
      case 'en_cours':
        return Icons.hourglass_empty;
      case 'resolue':
      case 'résolue':
        return Icons.check_circle_outline;
      case 'fermee':
      case 'fermée':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

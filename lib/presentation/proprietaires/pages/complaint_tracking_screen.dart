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
import 'complaint_screens/complaint_tracking_state.dart';
import 'complaint_screens/complaint_detail_screen.dart';
import 'package:intl/intl.dart';

class ComplaintTrackingScreen extends ConsumerStatefulWidget {
  const ComplaintTrackingScreen({super.key});

  @override
  ConsumerState<ComplaintTrackingScreen> createState() =>
      _ComplaintTrackingScreenState();
}

class _ComplaintTrackingScreenState
    extends ConsumerState<ComplaintTrackingScreen> {
  // TODO: Récupérer l'ID du propriétaire depuis le système d'authentification
  final int _ownerId = 1; // À remplacer par l'ID réel du propriétaire connecté

  @override
  void initState() {
    super.initState();
    // Charger les plaintes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(complaintTrackingControllerProvider.notifier)
          .loadComplaints(_ownerId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1. Ouverte':
        return AppColors.accentRed; // Accent principal
      case '2. Réception':
        return AppColors.primaryDark; // Sombre pour accusé
      case '3. En Cours de Résolution':
        return AppColors.accentRed.withOpacity(0.75); // Variation accent
      case '4. Résolue':
        return AppColors.primaryDark.withOpacity(0.7); // Sombre atténué
      case '5. Fermée':
        return AppColors.primaryDark.withOpacity(0.45); // Sombre léger
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

  Future<void> _refreshComplaints() async {
    await ref
        .read(complaintTrackingControllerProvider.notifier)
        .refreshComplaints(_ownerId);
  }

  void _openComplaintDetail(complaint) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ComplaintDetailScreen(
          complaint: complaint,
          ownerId: _ownerId,
        ),
      ),
    );

    // Si la plainte a été mise à jour, rafraîchir la liste
    if (result == true) {
      _refreshComplaints();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintTrackingControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _refreshComplaints,
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plaintes',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.status == ComplaintStatus.loaded
                            ? '${state.complaints.length} plainte${state.complaints.length > 1 ? 's' : ''}'
                            : 'Chargement...',
                        style: TextStyle(
                          color: AppColors.primaryDark.withOpacity(0.55),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshComplaints,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: _buildContent(state, dateFormat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ComplaintTrackingState state, DateFormat dateFormat) {
    if (state.status == ComplaintStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == ComplaintStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.accentRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshComplaints,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.primaryDark.withOpacity(0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune plainte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les plaintes de vos locataires apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Liste des plaintes
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.complaints.length,
      itemBuilder: (context, index) {
        final complaint = state.complaints[index];
        final decisionLabel = _getDecisionLabel(complaint.statutPlainte);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _openComplaintDetail(complaint),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec statut
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint.statutPlainte)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(complaint.statutPlainte),
                          color: _getStatusColor(complaint.statutPlainte),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint.sujet,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(complaint.statutPlainte)
                                    .withOpacity(0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                complaint.statutPlainte,
                                style: TextStyle(
                                  color:
                                      _getStatusColor(complaint.statutPlainte),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (decisionLabel != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: decisionLabel == 'Rejetée'
                                      ? AppColors.accentRed.withOpacity(0.14)
                                      : AppColors.primaryDark.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  decisionLabel,
                                  style: TextStyle(
                                    color: decisionLabel == 'Rejetée'
                                        ? AppColors.accentRed
                                        : AppColors.primaryDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryDark.withOpacity(0.72),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Pied avec date et informations
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.primaryDark.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(complaint.dateCreation),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Bien #${complaint.idBien}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryDark.withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

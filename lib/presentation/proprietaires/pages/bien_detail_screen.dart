// ===============================
// 🏠 Écran : Détails d'un Bien
//
// Ce fichier affiche les détails complets d'un bien immobilier
// avec la liste des locataires et invitations associés.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : UI pour afficher les détails d'un bien
// Utilisé par : Propriétaires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../config/colors.dart';
import '../../../data/models/bien_model.dart';
import '../../../data/models/invitation_model.dart';
import '../../../core/di/providers.dart';
import '../../shared/widgets/invitation_modal.dart';
import '../../shared/widgets/invitation_list_widget.dart';

class BienDetailScreen extends ConsumerStatefulWidget {
  final BienModel bien;

  const BienDetailScreen({super.key, required this.bien});

  @override
  ConsumerState<BienDetailScreen> createState() => _BienDetailScreenState();
}

class _BienDetailScreenState extends ConsumerState<BienDetailScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  List<InvitationModel> _invitations = [];

  // Liste fictive de locataires pour la démo
  // TODO: Remplacer par les vrais locataires depuis Appwrite
  List<Map<String, dynamic>> _locataires = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recharger les données quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed) {
      _loadInvitations();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadLocataires(),
      _loadInvitations(),
    ]);
  }

  Future<void> _loadLocataires() async {
    // TODO: Charger les locataires depuis Appwrite via les contrats
    setState(() {
      _locataires = [];
    });
  }

  Future<void> _loadInvitations() async {
    try {
      final invitationService = ref.read(invitationServiceProvider);
      final invitations = await invitationService.getInvitationsByBien(
        widget.bien.appwriteId ?? '',
      );
      if (mounted) {
        setState(() {
          _invitations = invitations;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement invitations: $e');
    }
  }

  String _getTypeDisplay(String type) {
    final map = {
      'appartement': 'Appartement',
      'maison': 'Maison',
      'studio': 'Studio',
      'villa': 'Villa',
      'duplex': 'Duplex',
      'local_commercial': 'Local commercial',
      'bureau': 'Bureau',
      'terrain': 'Terrain',
    };
    return map[type] ?? type;
  }

  String _formatMontant(double montant) {
    return '${montant.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} FCFA';
  }

  Future<void> _retirerLocataire(Map<String, dynamic> locataire) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retirer le locataire'),
        content: Text(
          'Voulez-vous vraiment retirer ${locataire['nom']} de ce bien ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        // TODO: Implémenter la suppression du locataire dans Appwrite
        setState(() {
          _locataires.removeWhere((l) => l['id'] == locataire['id']);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${locataire['nom']} a été retiré'),
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
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  /// Ouvre le modal d'invitation et recharge les invitations après succès
  Future<void> _inviterLocataire() async {
    final invitation = await showInvitationModal(
      context: context,
      ref: ref,
      bien: widget.bien,
    );

    if (invitation != null) {
      // Recharger les invitations
      await _loadInvitations();

      // Afficher le message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation envoyée à ${invitation.emailLocataire}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Annuler une invitation en attente
  Future<void> _cancelInvitation(InvitationModel invitation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler l\'invitation'),
        content: Text(
          'Voulez-vous vraiment annuler l\'invitation envoyée à ${invitation.emailLocataire} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        final invitationService = ref.read(invitationServiceProvider);
        await invitationService.cancelInvitation(invitation.id!);
        await _loadInvitations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation annulée'),
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
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bien = widget.bien;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // AppBar avec image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.primaryDark,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      bien.photosUrls != null && bien.photosUrls!.isNotEmpty
                          ? Image.file(
                              File(bien.photosUrls!.first),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primaryDark.withOpacity(0.3),
                                child: const Icon(
                                  Icons.home,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.primaryDark.withOpacity(0.3),
                              child: const Icon(
                                Icons.home,
                                size: 80,
                                color: Colors.white54,
                              ),
                            ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Infos en bas
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTypeDisplay(bien.type ?? 'autre'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bien.nom,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    bien.adresse,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loyer
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loyer mensuel',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'par mois',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatMontant(bien.loyerMensuel),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description
                    if (bien.description != null &&
                        bien.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bien.description!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                    // Caractéristiques
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Caractéristiques',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              if (bien.surface != null)
                                _buildCaracteristique(
                                  Icons.square_foot,
                                  '${bien.surface!.toStringAsFixed(0)} m²',
                                ),
                              if (bien.nombrePieces != null)
                                _buildCaracteristique(
                                  Icons.meeting_room,
                                  '${bien.nombrePieces} pièces',
                                ),
                              if (bien.nombreChambres != null)
                                _buildCaracteristique(
                                  Icons.bed,
                                  '${bien.nombreChambres} chambres',
                                ),
                              if (bien.nombreSallesDeBain != null)
                                _buildCaracteristique(
                                  Icons.bathroom,
                                  '${bien.nombreSallesDeBain} SDB',
                                ),
                              _buildCaracteristique(
                                Icons.home_work,
                                _getTypeDisplay(bien.type ?? 'autre'),
                              ),
                              _buildCaracteristique(
                                bien.statut == 'disponible'
                                    ? Icons.check_circle
                                    : Icons.person,
                                bien.statut == 'disponible'
                                    ? 'Disponible'
                                    : 'Occupé',
                                color: bien.statut == 'disponible'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Locataires
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Locataires',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: _inviterLocataire,
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Inviter'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Liste des locataires
                    if (_locataires.isEmpty && _invitations.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun locataire',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Invitez un locataire pour ce bien',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _inviterLocataire,
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('Inviter un locataire'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Liste des locataires existants
                    if (_locataires.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _locataires.length,
                        itemBuilder: (context, index) {
                          final locataire = _locataires[index];
                          return _buildLocataireCard(locataire);
                        },
                      ),

                    // Liste des invitations envoyées
                    if (_invitations.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      InvitationListWidget(
                        invitations: _invitations,
                        onRefresh: _loadInvitations,
                        onCancel: _cancelInvitation,
                      ),
                    ],

                    const SizedBox(height: 100), // Espace pour le FAB
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCaracteristique(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primaryDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.primaryDark,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocataireCard(Map<String, dynamic> locataire) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryDark.withOpacity(0.1),
          child: Text(
            (locataire['nom'] as String).substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          locataire['nom'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(locataire['email'] ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _retirerLocataire(locataire),
          tooltip: 'Retirer',
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../../../config/colors.dart';
import '../../../config/environment.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/appwrite_service.dart';
import '../../../data/models/invitation_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isProcessing = false;
  String? _processingInvitationId;
  List<InvitationModel> _invitations = [];

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    try {
      final result = await ref.read(pendingInvitationsProvider.future);
      setState(() {
        _invitations = result;
      });
    } catch (e) {
      debugPrint('Erreur chargement invitations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingInvitations = ref.watch(pendingInvitationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.accentRed,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Rafraîchir les compteurs avant de revenir
            ref.invalidate(totalNotificationsCountProvider);
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: pendingInvitations.when(
        data: (invitations) {
          _invitations = invitations; // Garder une copie locale
          
          if (invitations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _refreshAllData,
                    child: const Text('Rafraîchir'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _refreshAllData,
            child: ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                final invitation = invitations[index];
                return _buildInvitationCard(invitation);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _refreshAllData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationCard(InvitationModel invitation) {
    final isProcessingThis = _isProcessing && _processingInvitationId == invitation.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.bienNom,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Propriétaire: ${invitation.proprietaireNom}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Statut badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: invitation.statut == InvitationStatus.pending
                        ? Colors.amber.shade100
                        : invitation.statut == InvitationStatus.accepted
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invitation.statut.displayName,
                    style: TextStyle(
                      color: invitation.statut == InvitationStatus.pending
                          ? Colors.amber.shade800
                          : invitation.statut == InvitationStatus.accepted
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Loyer: ${invitation.loyerMensuel.toStringAsFixed(0)} FCFA/mois',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (invitation.charges != null && invitation.charges! > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Charges: ${invitation.charges!.toStringAsFixed(0)} FCFA/mois',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (invitation.message != null && invitation.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Message: ${invitation.message!}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 16),
            if (invitation.statut == InvitationStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isProcessingThis)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else ...[
                    OutlinedButton(
                      onPressed: () => _rejectInvitation(invitation),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Refuser'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _acceptInvitation(invitation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Accepter'),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptInvitation(InvitationModel invitation) async {
    if (!invitation.canBeAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cette invitation est ${invitation.isExpired ? 'expirée' : 'déjà traitée'}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingInvitationId = invitation.id;
    });

    try {
      final currentUser = ref.read(currentUserIdProvider);
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour accepter l\'invitation'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isProcessing = false;
          _processingInvitationId = null;
        });
        return;
      }

      // ✅ CORRECTION : Utiliser la méthode acceptInvitationAsExistingUser
      final invitationService = ref.read(invitationServiceProvider);
      await invitationService.acceptInvitationAsExistingUser(
        token: invitation.token,
        userId: currentUser as String,
      );

      // ✅ Mettre à jour le statut du bien
      await _updateBienStatusForProprietaire(invitation);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation acceptée avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Rafraîchir les données après un court délai
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshAllData();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Erreur acceptInvitation: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingInvitationId = null;
        });
      }
    }
  }

  Future<void> _rejectInvitation(InvitationModel invitation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser l\'invitation'),
        content: const Text('Êtes-vous sûr de vouloir refuser cette invitation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
      _processingInvitationId = invitation.id;
    });

    try {
      // ✅ CORRECTION : Utiliser rejectInvitation avec token
      final invitationService = ref.read(invitationServiceProvider);
      await invitationService.rejectInvitation(invitation.token);

      // ✅ Mettre à jour le statut dans la collection invitations
      await _updateInvitationStatus(invitation, 'rejected');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation refusée'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Rafraîchir les données
      await Future.delayed(const Duration(milliseconds: 300));
      await _refreshAllData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Erreur rejectInvitation: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingInvitationId = null;
        });
      }
    }
  }

  Future<void> _updateBienStatusForProprietaire(InvitationModel invitation) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final databases = Databases(appwriteService.client);
      
      await databases.updateDocument(
        databaseId: Environment.databaseId,
        collectionId: Environment.biensCollectionId,
        documentId: invitation.bienId,
        data: {
          'statut': 'occupe',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Statut du bien ${invitation.bienNom} mis à jour: occupe');
    } catch (e) {
      debugPrint('❌ Erreur mise à jour statut bien: $e');
      // Ne pas bloquer le processus principal
    }
  }

  Future<void> _updateInvitationStatus(InvitationModel invitation, String status) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final databases = Databases(appwriteService.client);
      
      await databases.updateDocument(
        databaseId: Environment.databaseId,
        collectionId: Environment.invitationsCollectionId,
        documentId: invitation.id!,
        data: {
          'statut': status,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Invitation ${invitation.id} mise à jour: $status');
    } catch (e) {
      debugPrint('❌ Erreur mise à jour invitation: $e');
    }
  }

  Future<void> _refreshAllData() async {
    // Invalider tous les providers
    ref.invalidate(pendingInvitationsProvider);
    ref.invalidate(totalNotificationsCountProvider);
    
    // Recharger localement
    await _loadInvitations();
  }
}
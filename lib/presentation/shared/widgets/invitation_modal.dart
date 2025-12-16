// Fichier : lib/presentation/shared/widgets/invitation_modal.dart
// Widget réutilisable pour inviter un locataire

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/bien_model.dart';
import '../../../data/models/invitation_model.dart';

/// Affiche le modal d'invitation d'un locataire
/// Retourne l'invitation créée si succès, null sinon
Future<InvitationModel?> showInvitationModal({
  required BuildContext context,
  required WidgetRef ref,
  required BienModel bien,
}) async {
  return showModalBottomSheet<InvitationModel?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _InvitationModalContent(bien: bien, ref: ref),
  );
}

class _InvitationModalContent extends StatefulWidget {
  final BienModel bien;
  final WidgetRef ref;

  const _InvitationModalContent({
    required this.bien,
    required this.ref,
  });

  @override
  State<_InvitationModalContent> createState() => _InvitationModalContentState();
}

class _InvitationModalContentState extends State<_InvitationModalContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _formatMontant(double montant) {
    return '${montant.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} FCFA';
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure the bien has a valid appwriteId — if not, offer to save it now
    BienModel targetBien = widget.bien;
    if (targetBien.appwriteId == null || targetBien.appwriteId!.isEmpty) {
      final save = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bien non enregistré'),
          content: const Text('Le bien doit être enregistré avant d\'envoyer une invitation. Voulez-vous enregistrer le bien maintenant ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enregistrer')),
          ],
        ),
      );

      if (save != true) return;

      // Attempt to create the bien
      setState(() => _isLoading = true);
      try {
        final bienRepository = widget.ref.read(bienRepositoryProvider);
        final created = await bienRepository.createBien(widget.bien);
        // Refresh the list so the new bien appears
        widget.ref.invalidate(proprietaireBiensProvider);
        targetBien = created;
        debugPrint('✅ Bien créé automatiquement avant invitation: ${created.appwriteId}');
      } catch (e, st) {
        debugPrint('❌ Erreur création automatique du bien: $e');
        debugPrint(st.toString());
        setState(() => _isLoading = false);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Erreur'),
              content: Text('Impossible d\'enregistrer le bien: ${e.toString()}'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
            ),
          );
        }
        return;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    setState(() => _isLoading = true);

    debugPrint('⏳ Envoi d\'invitation vers: ${_emailController.text.trim()} pour bien ${widget.bien.appwriteId}');

    try {
      final invitationService = widget.ref.read(invitationServiceProvider);

      // Debug: log the bien id we're about to use
      debugPrint('Modal: sending invitation for bien.appwriteId=${targetBien.appwriteId}, bien.nom=${targetBien.nom}');

      // Verify the bien exists in Appwrite (helpful if the local model is stale)
      if (targetBien.appwriteId != null && targetBien.appwriteId!.isNotEmpty) {
        try {
          final bienRepository = widget.ref.read(bienRepositoryProvider);
          final fresh = await bienRepository.getBienById(targetBien.appwriteId!);
          targetBien = fresh;
          debugPrint('Modal: bien verified on server: ${fresh.appwriteId}');
        } catch (e) {
          debugPrint('Modal: failed to verify bien on server: $e');
          setState(() => _isLoading = false);
          if (mounted) {
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Bien introuvable'),
                content: const Text('Le bien sélectionné semble introuvable sur le serveur. Veuillez rafraîchir la liste.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
              ),
            );
          }
          return;
        }
      }

      final result = await invitationService.createInvitation(
        bien: targetBien,
        emailLocataire: _emailController.text.trim(),
      );

      debugPrint('✅ Invitation créée: token=${result.invitation.token}');

      if (mounted) {
        // Afficher un message indiquant que l'invitation a été envoyée via notification in-app
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Expanded(child: Text('Invitation créée !')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Invitation envoyée via notification à ${_emailController.text.trim()}',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Le locataire recevra l\'invitation directement dans son compte PayRent (notifications in-app).',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );

        // Rafraîchir le compteur de notifications non lues
        widget.ref.invalidate(unreadNotificationsCountProvider);

        Navigator.pop(context, result.invitation);
      }
    } catch (e, st) {
      // Log détaillé pour debug
      debugPrint('❌ Erreur lors de la création de l\'invitation: $e');
      debugPrint(st.toString());

      setState(() => _isLoading = false);
      if (mounted) {
        final msg = e.toString();
        // Cas spécial: email non associé à un utilisateur
        if (msg.contains("n'est pas associé à un utilisateur") || msg.contains('n\'est pas associé')) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Email non-utilisateur'),
              content: const Text('Cet email n\'est pas associé à un utilisateur PayRent. Aucune invitation n\'a été créée ni envoyée.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Erreur lors de l\'envoi'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.toString()),
                    const SizedBox(height: 12),
                    Text(
                      st.toString().split('\n').take(5).join('\n'),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_add, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inviter un locataire',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                        Text(
                          widget.bien.nom,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Email (requis)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email du locataire *',
                  labelStyle: const TextStyle(fontSize: 13),
                  hintText: 'exemple@email.com',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'email est requis';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (widget.bien.appwriteId == null || widget.bien.appwriteId!.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Le bien doit être enregistré avant d\'envoyer une invitation.',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),



              // Info loyer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Loyer: ${_formatMontant(widget.bien.loyerMensuel)}${widget.bien.charges != null ? ' + ${_formatMontant(widget.bien.charges!)} de charges' : ''}',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton envoyer
              ElevatedButton.icon(
                onPressed: (_isLoading || widget.bien.appwriteId == null || widget.bien.appwriteId!.isEmpty) ? null : _sendInvitation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Envoi en cours...' : 'Envoyer l\'invitation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

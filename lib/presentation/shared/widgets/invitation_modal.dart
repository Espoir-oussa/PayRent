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
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
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
        nomLocataire: _nomController.text.trim().isNotEmpty
            ? _nomController.text.trim()
            : null,
        prenomLocataire: _prenomController.text.trim().isNotEmpty
            ? _prenomController.text.trim()
            : null,
        telephoneLocataire: _telephoneController.text.trim().isNotEmpty
            ? _telephoneController.text.trim()
            : null,
      );

      debugPrint('✅ Invitation créée: token=${result.invitation.token}, emailSent=${result.emailSent}');

      if (mounted) {
        // Afficher le lien à partager
        final invitationLink = 'payrent://accept-invitation?token=${result.invitation.token}';
        // Print more debug info for developers
        debugPrint('🔗 Invitation link (modal): $invitationLink');
        debugPrint('🔑 Invitation token (modal): ${result.invitation.token}');

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
                // Afficher le statut de l'email
                if (result.emailSent)
                  Text(
                    '✅ Email envoyé à ${_emailController.text.trim()}',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                  )
                else
                  Text(
                    '⚠️ L\'email n\'a pas pu être envoyé. Partagez le lien ci-dessous.',
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Partagez ce lien avec le locataire (WhatsApp, SMS...) :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        invitationLink,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontFamily: 'monospace',
                    ),
                      ),
                      const SizedBox(height: 8),
                      Text('Token:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      SelectableText(result.invitation.token, style: TextStyle(fontFamily: 'monospace', fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: invitationLink));
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Lien copié !')),
                  );
                },
                child: const Text('Copier le lien'),
              ),
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

        Navigator.pop(context, result.invitation);
      }
    } catch (e, st) {
      // Log détaillé pour debug
      debugPrint('❌ Erreur lors de la création de l\'invitation: $e');
      debugPrint(st.toString());

      setState(() => _isLoading = false);
      if (mounted) {
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.bien.nom,
                          style: TextStyle(color: Colors.grey.shade600),
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
                  hintText: 'exemple@email.com',
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

              // Nom et Prénom
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prenomController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _nomController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  hintText: '+229 XX XX XX XX',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

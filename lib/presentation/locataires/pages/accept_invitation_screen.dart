// Fichier : lib/presentation/locataires/pages/accept_invitation_screen.dart
// Écran d'acceptation d'invitation pour les locataires
// Simplifié : création automatique du compte sans formulaire d'inscription

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/invitation_model.dart';
// ...existing imports
import 'auth_screens/tenant_login_screen.dart';
import 'home_tenant_screen.dart';
import 'package:flutter/services.dart';

class AcceptInvitationScreen extends ConsumerStatefulWidget {
  final String token;
  final String initialAction;
  final String? initialCode;
  final String? initialTempPassword;

  const AcceptInvitationScreen({
    super.key,
    required this.token,
    this.initialAction = 'accept',
    this.initialCode,
    this.initialTempPassword,
  });

  @override
  ConsumerState<AcceptInvitationScreen> createState() =>
      _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState
    extends ConsumerState<AcceptInvitationScreen> {
  bool _isLoading = true;
  bool _isAccepting = false;
  bool _isVerifyingCode = false;
  InvitationModel? _invitation;
  String? _errorMessage;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvitation();
  }

  Future<void> _loadInvitation() async {
    try {
      final invitationService = ref.read(invitationServiceProvider);
      final invitation =
          await invitationService.getInvitationByToken(widget.token);

      if (invitation == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invitation non trouvée ou lien invalide.';
        });
        return;
      }

      if (invitation.isExpired) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Cette invitation a expiré.';
        });
        return;
      }

      if (invitation.statut != InvitationStatus.pending) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Cette invitation a déjà été ${invitation.statut.displayName.toLowerCase()}.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _invitation = invitation;
      });

      // Si un code initial est présent (ex: via le lien), remplir et valider automatiquement
      if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
        _codeController.text = widget.initialCode!;
        // Déclencher la validation après un court délai pour permettre au widget de se stabiliser
        Future.delayed(const Duration(milliseconds: 300), () {
          _verifyAndAccept();
        });
      }

      // Si un mot de passe temporaire initial est présent (ex: via le lien), tenter l'acceptation auto
      if (widget.initialTempPassword != null && widget.initialTempPassword!.isNotEmpty) {
        Future.microtask(() async {
          try {
            final invitationService = ref.read(invitationServiceProvider);
            final result = await invitationService.acceptInvitationWithPassword(
              token: widget.token,
              temporaryPassword: widget.initialTempPassword!,
            );

            if (!mounted) return;
            // Afficher une alerte optionnelle avec le mot de passe
            final tempPassword = result['temporaryPassword'] as String? ?? widget.initialTempPassword!;
            await showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Invitation acceptée'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Votre compte a été créé et vous êtes connecté.'),
                    const SizedBox(height: 12),
                    SelectableText(tempPassword, style: const TextStyle(fontFamily: 'monospace')),
                  ],
                ),
                actions: [
                  ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                ],
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeTenantScreen()),
              (route) => false,
            );
          } catch (e) {
            debugPrint('Erreur auto-accept via tempPass: $e');
          }
        });
      }

      // Si l'action initiale est "reject", afficher directement la boîte de dialogue de refus
      if (widget.initialAction == 'reject') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _rejectInvitation();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
  }

  Future<void> _acceptInvitation() async {
    // Nouveau flux : afficher le champ pour entrer le code et le vérifier
    if (mounted) {
      setState(() {
        _isAccepting = true;
      });
    }
    // focus will show the code field in UI; actual verification is done via button
    if (mounted) {
      setState(() {
        _isAccepting = false;
      });
    }
  }

  Future<void> _verifyAndAccept() async {
    // If a temp password was provided (deep link) we already attempted auto-accept in _loadInvitation.
    // Here we show a hint if user tries to manually verify without temp password.
    if (widget.initialTempPassword == null || widget.initialTempPassword!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez utiliser le lien reçu par email pour accepter l\'invitation et vous connecter automatiquement.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      setState(() {
        _isVerifyingCode = true;
      });
      // Debug: verification started
      if (kDebugMode) {
        debugPrint('🧪 Verification via temporary password (auto-login)');
      }
      final invitationService = ref.read(invitationServiceProvider);
      final result = await invitationService.acceptInvitationWithPassword(token: widget.token, temporaryPassword: widget.initialTempPassword!);

      if (mounted) {
          final tempPassword = result['temporaryPassword'] as String?;
          if (tempPassword != null && tempPassword.isNotEmpty) {
            // Show a dialog with the temporary password and option to copy
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: const Text('Invitation acceptée'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Votre compte a été créé avec succès.'),
                    const SizedBox(height: 12),
                    const Text('Mot de passe temporaire :', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(tempPassword, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                    const SizedBox(height: 12),
                    const Text('Le mot de passe a aussi été envoyé par email. Changez-le dès votre première connexion.'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: tempPassword));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mot de passe copié dans le presse-papier')),
                      );
                    },
                    child: const Text('Copier'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitation acceptée — compte créé.'), backgroundColor: Colors.green),
            );
          }

        // Après acceptation et auto-login, rediriger directement vers l'interface locataire
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeTenantScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        if (msg.contains('Un compte existe déjà')) {
          _showExistingAccountDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  void _showExistingAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Compte existant'),
        content: const Text(
          'Un compte existe déjà avec cette adresse email. '
          'Voulez-vous vous connecter pour accepter l\'invitation ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TenantLoginScreen(
                    invitationToken: widget.token,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectInvitation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Refuser l\'invitation'),
        content: const Text(
          'Êtes-vous sûr de vouloir refuser cette invitation ? '
          'Vous ne pourrez plus accéder à ce logement.',
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
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final invitationService = ref.read(invitationServiceProvider);
        await invitationService.rejectInvitation(widget.token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation refusée.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildInvitationView(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oups !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationView() {
    final invitation = _invitation!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // Icône
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                size: 64,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Titre
          Text(
            'Invitation à rejoindre',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            invitation.bienNom,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 32),

          // Carte d'information du propriétaire
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person,
                          color: Colors.blue.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Propriétaire',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            invitation.proprietaireNom,
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.payments, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Loyer: ${invitation.loyerMensuel.toStringAsFixed(0)} FCFA/mois',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (invitation.charges != null && invitation.charges! > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.receipt_long,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Charges: ${invitation.charges!.toStringAsFixed(0)} FCFA/mois',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Message du propriétaire
          if (invitation.message != null && invitation.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.message,
                          color: Colors.grey.shade600, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Message du propriétaire',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invitation.message!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Information sur la création de compte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'En acceptant, un compte sera créé automatiquement avec votre email. Vous pourrez ensuite personnaliser votre mot de passe.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bouton Accepter
          ElevatedButton.icon(
            onPressed: _isAccepting ? null : _acceptInvitation,
            icon: _isAccepting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              _isAccepting ? 'Création du compte...' : 'Accepter l\'invitation',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Champ code de connexion (visible après avoir appuyé sur Accepter)
          if (!_isLoading && _invitation != null) ...[
            const SizedBox(height: 12),
            // Debug info panel (visible only in debug builds)
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEBUG: Invitation info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text('token: ${invitation.token}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                    const SizedBox(height: 6),
                    Text('code hash (prefix): ${invitation.connectionCodeHash != null ? invitation.connectionCodeHash!.substring(0, math.min(8, invitation.connectionCodeHash!.length)) + '...' : 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                    const SizedBox(height: 6),
                    Text('expiry: ${invitation.connectionCodeExpiry?.toLocal().toString() ?? 'N/A'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                    const SizedBox(height: 6),
                    Text('used: ${invitation.connectionCodeUsed ?? false}', style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code de connexion',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Entrez le code reçu par email',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isVerifyingCode ? null : _verifyAndAccept,
              child: _isVerifyingCode
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Valider le code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Bouton Refuser
          OutlinedButton.icon(
            onPressed: _isAccepting ? null : _rejectInvitation,
            icon: const Icon(Icons.close),
            label: const Text(
              'Refuser l\'invitation',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Séparateur
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),

          // Bouton "J'ai déjà un compte"
          TextButton.icon(
            onPressed: _isAccepting
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TenantLoginScreen(
                          invitationToken: widget.token,
                        ),
                      ),
                    );
                  },
            icon: Icon(Icons.login, color: AppColors.primaryDark),
            label: Text(
              'J\'ai déjà un compte PayRent',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

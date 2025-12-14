// Fichier : lib/presentation/locataires/pages/auth_screens/tenant_login_screen.dart
// Écran de connexion pour les locataires

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/colors.dart';
import '../../../../core/di/providers.dart';
import '../home_tenant_screen.dart';

class TenantLoginScreen extends ConsumerStatefulWidget {
  final String? invitationToken;

  const TenantLoginScreen({
    super.key,
    this.invitationToken,
  });

  @override
  ConsumerState<TenantLoginScreen> createState() => _TenantLoginScreenState();
}

class _TenantLoginScreenState extends ConsumerState<TenantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appwriteService = ref.read(appwriteServiceProvider);

      await appwriteService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Si on a un token d'invitation, accepter l'invitation
      if (widget.invitationToken != null) {
        try {
          final user = await appwriteService.getCurrentUser();
          if (user != null) {
            final invitationService = ref.read(invitationServiceProvider);
            await invitationService.acceptInvitationWithExistingAccount(
              token: widget.invitationToken!,
              locataireId: user.$id,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation acceptée ! Bienvenue.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          // Si l'invitation échoue, on continue quand même vers l'accueil
          debugPrint('Erreur acceptation invitation: $e');
        }
      }

      if (mounted) {
        // Rediriger vers l'écran d'accueil du locataire
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeTenantScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        String errorMessage = 'Erreur de connexion';

        if (e.toString().contains('Invalid credentials')) {
          errorMessage = 'Email ou mot de passe incorrect';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage = 'Email invalide';
        } else if (e.toString().contains('user_not_found')) {
          errorMessage = 'Aucun compte trouvé avec cet email';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion locataire'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                if (widget.invitationToken != null) ...[
                  Text(
                    'Astuce : si vous venez d\'accepter une invitation, utilisez le mot de passe temporaire envoyé par email pour vous connecter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                ],

                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 64,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Connexion',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte locataire',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Bouton connexion
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

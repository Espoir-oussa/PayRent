// Fichier : lib/presentation/proprietaires/pages/auth_screens/owner_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'owner_login_state.dart';
import '../../../../config/colors.dart';
import '../../../../core/di/providers.dart';
import '../home_owner_screen.dart';
import 'owner_register_screen.dart';

class OwnerLoginScreen extends ConsumerStatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  ConsumerState<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends ConsumerState<OwnerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Écouter l'état du contrôleur
    final loginState = ref.watch(ownerLoginControllerProvider);

    // Écouter les changements d'état
    ref.listen<OwnerLoginState>(ownerLoginControllerProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeOwnerScreen()),
        );
      }
      if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur: ${next.errorMessage ?? "Vérifiez vos identifiants"}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    });

    // Fonction de soumission
    void handleLogin() {
      if (loginState.status != AuthStatus.loading) {
        ref.read(ownerLoginControllerProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text,
            );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 40.0, vertical: 24.0), // Reduced vertical padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo en haut - taille réduite
              const SizedBox(height: 20), // Small top spacing
              Align(
                child: Text(
                  'PayRent',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 5), // Reduced from 60

              // Sous-titre
              Text(
                'Gérez vos biens et vos locataires.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryDark.withOpacity(0.6),
                      fontSize: 16, // Slightly larger for better readability
                    ),
              ),
              const SizedBox(height: 40), // Reduced from 60

              // CHAMP EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onFieldSubmitted: (_) => handleLogin(),
              ),
              const SizedBox(height: 20), // Reduced from 30

              // CHAMP MOT DE PASSE avec icône de visibilité
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primaryDark.withOpacity(0.5),
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onFieldSubmitted: (_) => handleLogin(),
              ),
              const SizedBox(height: 12), // Reduced from 20

              // Lien Mot de Passe Oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Naviguer vers l'écran de mot de passe oublié
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: AppColors.accentRed,
                      fontFamily: 'MuseoModerno',
                      fontWeight: FontWeight.w600,
                      fontSize: 14, // Slightly smaller
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30), // Reduced from 50

              // BOUTON DE CONNEXION
              SizedBox(
                height: 52, // Slightly taller button for better touch target
                child: ElevatedButton(
                  onPressed: loginState.status == AuthStatus.loading
                      ? null
                      : handleLogin,
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: loginState.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textLight,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'SE CONNECTER',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                ),
              ),

              const SizedBox(height: 30), // Reduced from 40

              // Séparateur plus discret
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.primaryDark
                          .withOpacity(0.15), // More subtle
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12), // Reduced padding
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: AppColors.primaryDark
                            .withOpacity(0.4), // More subtle
                        fontFamily: 'MuseoModerno',
                        fontSize: 13, // Smaller
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.primaryDark
                          .withOpacity(0.15), // More subtle
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30), // Reduced from 40

              // Lien Créer un Compte
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const OwnerRegisterScreen()),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Vous n'avez pas de compte ? ",
                        style: TextStyle(
                          fontFamily: 'MuseoModerno',
                          color: AppColors.primaryDark,
                          fontSize: 14, // Consistent size
                        ),
                      ),
                      TextSpan(
                        text: "S'inscrire",
                        style: TextStyle(
                          fontFamily: 'MuseoModerno',
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Consistent size
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20), // Small bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

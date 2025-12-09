// Fichier : lib/presentation/proprietaires/pages/auth_screens/owner_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'owner_login_state.dart'; 
import '../../../../config/colors.dart';
import '../../../../core/di/providers.dart';
// 1. Import de l'écran de destination
import '../home_owner_screen.dart'; 
// 2. Import d'un écran d'inscription (à créer)
import 'owner_register_screen.dart'; 


class OwnerLoginScreen extends ConsumerWidget {
  const OwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialisation des contrôleurs de texte
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    // Écouter l'état du contrôleur
    final loginState = ref.watch(ownerLoginControllerProvider);

    // Écouter les changements d'état (navigation et erreurs)
    ref.listen<OwnerLoginState>(ownerLoginControllerProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        // 🔥 REDIRECTION VERS L'ÉCRAN D'ACCUEIL DU PROPRIÉTAIRE
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OwnerHomeScreen()),
        );
      }
      if (next.status == AuthStatus.failure) {
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${next.errorMessage ?? "Vérifiez vos identifiants"}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    });

    // Fonction de soumission
    void handleLogin() {
      if (loginState.status != AuthStatus.loading) {
        ref.read(ownerLoginControllerProvider.notifier).login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }
    }

    // Interface Utilisateur (Design Moderne/Minimaliste)
    return Scaffold(
      appBar: AppBar(
        title: Image.asset( 
          'assets/images/payrent_blanc.png',
          height: 30, // Taille réduite pour un look moderne
          color: AppColors.textLight, 
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: <Widget>[
              // Titre
              Text(
                'Accès Propriétaire',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 32, // Grande taille sans gras
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 10),
              
              // Sous-titre
              Text(
                'Gérez vos biens et vos locataires.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryDark.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 60),

              // CHAMP EMAIL (Utilise le style InputDecorationTheme du thème)
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 30),
              
              // CHAMP MOT DE PASSE
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),
              
              // Lien Mot de Passe Oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () { 
                    // TODO: Naviguer vers l'écran de mot de passe oublié 
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: AppColors.primaryDark.withOpacity(0.8)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              // BOUTON DE CONNEXION 
              ElevatedButton(
                onPressed: loginState.status == AuthStatus.loading ? null : handleLogin,
                style: Theme.of(context).elevatedButtonTheme.style, // Utilise le thème
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textLight,
                          // fontSize: 18, // Si vous souhaitez une taille spécifique
                        ),
                      ),
              ),
              
              const SizedBox(height: 40),
              
              // Lien Créer un Compte
              TextButton(
                onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const OwnerRegisterScreen()),
                    );
                },
                child: Text(
                  "Vous n'avez pas de compte ? S'inscrire",
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
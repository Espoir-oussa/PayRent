// Fichier : lib/presentation/proprietaires/pages/auth_screens/owner_login_screen.dart (MIS À JOUR)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'owner_login_controller.dart'; 
import 'owner_login_state.dart'; // Pour AuthStatus et OwnerLoginState
import '../../../../config/colors.dart';
import '../../../../core/di/providers.dart'; // Pour accéder au ownerLoginControllerProvider


class OwnerLoginScreen extends ConsumerWidget {
  const OwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Initialisation des contrôleurs de texte
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    // 2. Écouter l'état du contrôleur
    final loginState = ref.watch(ownerLoginControllerProvider);

    // 3. Écouter les changements d'état (pour la navigation ou les messages d'erreur)
    ref.listen<OwnerLoginState>(ownerLoginControllerProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        // Logique de navigation après succès (ex: aller au Tableau de Bord)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion réussie! Token: ${next.authToken}')),
        );
        // Navigator.of(context).pushReplacementNamed('/home_owner');
      }
      if (next.status == AuthStatus.failure) {
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${next.errorMessage}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    });

    // 4. Fonction de soumission
    void handleLogin() {
      if (loginState.status != AuthStatus.loading) {
        ref.read(ownerLoginControllerProvider.notifier).login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }
    }

    // 5. Interface Utilisateur
    return Scaffold(
      appBar: AppBar(
        title: Image.asset( 'assets/images/payrent_blanc.png',
        height: 100,
        color: AppColors.textLight, 
        ),
        centerTitle: true, // Pour centrer le logo dans l'AppBar
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // CHAMP EMAIL
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              // CHAMP MOT DE PASSE
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              
              // BOUTON DE CONNEXION
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleLogin,
                  child: loginState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: AppColors.textLight)
                      : const Text('Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
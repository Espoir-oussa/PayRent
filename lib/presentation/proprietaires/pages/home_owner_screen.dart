
// ===============================
// 🏠 Écran : Accueil Propriétaire
//
// Ce fichier définit l'interface utilisateur principale pour le propriétaire.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : Tableau de bord du propriétaire
// Utilisé par : Propriétaires
// ===============================

// TODO: Implémenter le widget HomeOwnerScreen
// class HomeOwnerScreen extends StatelessWidget {
//   // ...
// }


// Fichier : lib/presentation/proprietaires/pages/home_owner_screen.dart

import 'package:flutter/material.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Cet écran sera la première chose que le Propriétaire verra.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue Propriétaire!',
              style: TextStyle(fontSize: 24),
            ),
            // Ici viendra la liste des biens, les stats, etc.
          ],
        ),
      ),
    );
  }
}
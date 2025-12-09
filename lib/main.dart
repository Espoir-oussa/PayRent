// Fichier : lib/main.dart

import 'package:flutter/material.dart';
import 'config/theme.dart'; // Importez votre fichier de thème

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Locative',
      // Appliquez votre ThemeData ici
      theme: appTheme, 
      
      // Vous pouvez définir les routes ou simplement commencer par l'écran de login
      initialRoute: '/login_owner', 
      routes: {
        // Démarrez avec l'écran d'authentification du Propriétaire
        '/login_owner': (context) => const OwnerLoginScreen(), 
        // ... autres routes
      },
      // Note: Assurez-vous d'importer OwnerLoginScreen dans le fichier
    );
  }
}
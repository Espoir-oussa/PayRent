// Fichier : lib/main.dart (Mis à jour)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NOUVEL IMPORT
import 'config/theme.dart';
import 'presentation/proprietaires/pages/auth_screens/owner_login_screen.dart'; // Importez votre écran de login

void main() {
  // Le ProviderScope est OBLIGATOIRE pour utiliser Riverpod
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Locative',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/login_owner',
      routes: {
        // Assurez-vous d'avoir cet écran
        '/login_owner': (context) => const OwnerLoginScreen(),
        // ... autres routes
      },
    );
  }
}
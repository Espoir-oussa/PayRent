// Fichier : lib/main.dart (Mis à jour avec Appwrite)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'core/services/appwrite_service.dart';
import 'presentation/proprietaires/pages/auth_screens/owner_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Appwrite avant de lancer l'app
  AppwriteService().init();
  
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
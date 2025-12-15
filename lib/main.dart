// Fichier : lib/main.dart (Mis à jour avec Appwrite et Deep Linking)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';
import 'config/theme.dart';
import 'core/services/appwrite_service.dart';
import 'presentation/proprietaires/pages/auth_screens/owner_login_screen.dart';
import 'presentation/locataires/pages/accept_invitation_screen.dart';
import 'presentation/locataires/pages/home_tenant_screen.dart';

// Clé de navigation globale pour naviguer depuis n'importe où
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Appwrite avant de lancer l'app
  AppwriteService().init();

  // Le ProviderScope est OBLIGATOIRE pour utiliser Riverpod
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Gérer le lien initial (quand l'app démarre via un lien)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(Uri.parse(initialLink));
      }
    } on PlatformException catch (e) {
      debugPrint('Erreur lors de la récupération du lien initial: $e');
    }

    // Écouter les liens entrants (quand l'app est déjà ouverte)
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(Uri.parse(link));
      }
    }, onError: (err) {
      debugPrint('Erreur deep link stream: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('📲 Deep link reçu: $uri');

    // Gérer le lien d'acceptation d'invitation
    // Format: payrent://accept-invitation?token=xxx
    // ou: https://payrent.app/accept-invitation?token=xxx
    final path = uri.path.isEmpty ? uri.host : uri.path;

    if (path == 'accept-invitation' || path == '/accept-invitation') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        debugPrint('🎫 Token d\'invitation: $token');

        // Naviguer vers l'écran d'acceptation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AcceptInvitationScreen(token: token),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PayRent - Gestion Locative',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/login_owner',
      onGenerateRoute: _generateRoute,
      routes: {
        '/login_owner': (context) => const OwnerLoginScreen(),
        '/tenant-home-debug': (context) => const HomeTenantScreen(),
      },
    );
  }

  /// Génère les routes dynamiquement pour gérer les deep links
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    // Gérer le lien d'acceptation d'invitation
    // Format: /accept-invitation?token=xxx ou payrent://accept-invitation?token=xxx
    if (uri.path == '/accept-invitation' ||
        uri.path.contains('accept-invitation')) {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        return MaterialPageRoute(
          builder: (context) => AcceptInvitationScreen(token: token),
          settings: settings,
        );
      }
    }

    // Route par défaut
    return null;
  }
}

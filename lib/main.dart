// Fichier : lib/main.dart (Mis à jour avec Appwrite, Deep Linking et Auto-Update)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'config/theme.dart';
import 'core/services/appwrite_service.dart';

import 'presentation/shared/pages/splash_screen.dart';
import 'presentation/proprietaires/pages/auth_screens/owner_login_screen.dart';
import 'presentation/locataires/pages/accept_invitation_screen.dart';

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
  StreamSubscription<Uri>? _linkSubscription;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    // Les vérifications automatiques de mise à jour ont été supprimées.
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // Vérification des mises à jour et installation automatique supprimées.
  /// Initialiser le deep linking avec AppLinks
  Future<void> _initDeepLinks() async {
    // Lien initial
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } on PlatformException catch (e) {
      debugPrint('Erreur lors de la récupération du lien initial: $e');
    }

    // Écouter les liens entrants
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Erreur deep link stream: $err');
    });
  }

  /// Gestion des deep links
  void _handleDeepLink(Uri uri) {
    debugPrint('📲 Deep link reçu: $uri');

    final path = uri.path.isEmpty ? uri.host : uri.path;

    if (path == 'accept-invitation' || path == '/accept-invitation') {
      final token = uri.queryParameters['token'];
      final action = uri.queryParameters['action'] ?? 'accept';
      final tempPass = uri.queryParameters['tempPass'];
      final code = uri.queryParameters['code'];

      if (token != null && token.isNotEmpty) {
        debugPrint("🎫 Token d'invitation: $token, Action: $action");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AcceptInvitationScreen(
                token: token,
                initialAction: action,
                initialCode: code,
                initialTempPassword: tempPass,
              ),
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
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login_owner': (context) => const OwnerLoginScreen(),
      },
    );
  }

  /// Génération des routes dynamiques pour gérer les deep links
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    if (uri.path == '/accept-invitation' ||
        uri.path.contains('accept-invitation')) {
      final token = uri.queryParameters['token'];
      final action = uri.queryParameters['action'] ?? 'accept';
      final tempPass = uri.queryParameters['tempPass'];
      final code = uri.queryParameters['code'];

      if (token != null && token.isNotEmpty) {
        return MaterialPageRoute(
          builder: (context) => AcceptInvitationScreen(
            token: token,
            initialAction: action,
            initialCode: code,
            initialTempPassword: tempPass,
          ),
          settings: settings,
        );
      }
    }

    return null;
  }
}

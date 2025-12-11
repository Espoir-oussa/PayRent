// Fichier : lib/main.dart (Mis à jour avec Appwrite, Deep Linking et Auto-Update)

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';
import 'config/theme.dart';
import 'core/services/appwrite_service.dart';
import 'core/services/update_service.dart';
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
  StreamSubscription? _linkSubscription;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    // Vérifier les mises à jour après le démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Vérifier si une mise à jour est disponible
  Future<void> _checkForUpdates() async {
    // Attendre un peu que l'app soit complètement chargée
    await Future.delayed(const Duration(seconds: 2));

    // Seulement sur Android
    if (!Platform.isAndroid) return;

    try {
      final result = await _updateService.checkForUpdate();

      if (result.updateAvailable && result.latestVersion != null) {
        debugPrint(
            '🔄 Mise à jour disponible: ${result.latestVersion!.version}');

        // Afficher le dialogue de mise à jour
        final context = navigatorKey.currentContext;
        if (context != null) {
          UpdateService.showUpdateDialog(
            context,
            result.latestVersion!,
            result.currentVersion,
          );
        }
      } else {
        debugPrint("✅ L'application est à jour (${result.currentVersion})");
      }
    } catch (e) {
      debugPrint('⚠️ Impossible de vérifier les mises à jour: $e');
    }
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
    // Format: payrent://accept-invitation?token=xxx&action=accept
    // ou: https://payrent.app/accept-invitation?token=xxx
    final path = uri.path.isEmpty ? uri.host : uri.path;

    if (path == 'accept-invitation' || path == '/accept-invitation') {
      final token = uri.queryParameters['token'];
      final action = uri.queryParameters['action'] ?? 'accept';
      final tempPass = uri.queryParameters['tempPass'];
      final code = uri.queryParameters['code'];

      if (token != null && token.isNotEmpty) {
        debugPrint("🎫 Token d'invitation: $token, Action: $action");

        // Naviguer vers l'écran d'acceptation avec l'action
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

  /// Génère les routes dynamiquement pour gérer les deep links
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    // Gérer le lien d'acceptation d'invitation
    // Format: /accept-invitation?token=xxx&action=accept ou payrent://accept-invitation?token=xxx&action=reject
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

    // Route par défaut
    return null;
  }
}

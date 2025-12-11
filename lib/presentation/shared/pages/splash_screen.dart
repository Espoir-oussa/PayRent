// Fichier : lib/presentation/shared/pages/splash_screen.dart
// Écran de démarrage avec vérification de session

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../proprietaires/pages/auth_screens/owner_login_screen.dart';
import '../../proprietaires/pages/home_owner_screen.dart';
import '../../locataires/pages/home_tenant_screen.dart';
import 'no_connection_page.dart';

/// État de l'authentification
enum AuthState {
  loading,
  authenticated,
  unauthenticated,
}

/// Provider pour l'état de l'authentification au démarrage
final authStateProvider = FutureProvider<AuthCheckResult>((ref) async {
  // Simuler un délai minimum pour l'effet visuel du splash
  await Future.delayed(const Duration(milliseconds: 1500));

  try {
    // Vérifier si l'utilisateur est connecté via Appwrite
    final appwriteService = ref.watch(appwriteServiceProvider);
    final isLoggedIn = await appwriteService.isLoggedIn();

    if (!isLoggedIn) {
      return AuthCheckResult(state: AuthState.unauthenticated);
    }

    // Récupérer les informations de l'utilisateur
    final user = await appwriteService.getCurrentUser();
    if (user == null) {
      return AuthCheckResult(state: AuthState.unauthenticated);
    }

    // Récupérer le profil pour déterminer le rôle
    final userProfile =
        await ref.watch(authRepositoryAppwriteProvider).getCurrentUser();

    if (userProfile == null) {
      return AuthCheckResult(state: AuthState.unauthenticated);
    }

    return AuthCheckResult(
      state: AuthState.authenticated,
      userRole: userProfile.typeRole,
      userId: userProfile.appwriteId ?? user.$id,
    );
  } catch (e) {
    debugPrint('Erreur vérification session: $e');
    return AuthCheckResult(state: AuthState.unauthenticated);
  }
});

/// Résultat de la vérification d'authentification
class AuthCheckResult {
  final AuthState state;
  final String? userRole;
  final String? userId;

  AuthCheckResult({
    required this.state,
    this.userRole,
    this.userId,
  });
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToScreen(AuthCheckResult result) {
    Widget destination;

    switch (result.state) {
      case AuthState.authenticated:
        // Rediriger selon le rôle
        if (result.userRole == 'locataire') {
          destination = const HomeTenantScreen();
        } else {
          destination = const HomeOwnerScreen();
        }
        break;
      case AuthState.unauthenticated:
      case AuthState.loading:
        destination = const OwnerLoginScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  bool _isConnectionError(Object? error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('internet');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthCheckResult>>(authStateProvider,
        (previous, next) {
      next.when(
        data: (result) {
          _navigateToScreen(result);
        },
        error: (error, stack) {
          if (_isConnectionError(error)) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NoConnectionPage()),
            );
          }
        },
        loading: () {},
      );
    });

    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Logo centré
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/payrent_marron.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Loader barre horizontale en bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: authState.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Icon(Icons.error_outline_rounded,
                      color: AppColors.accentRed, size: 32),
                ),
                data: (_) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

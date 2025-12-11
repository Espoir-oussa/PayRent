// Fichier : lib/presentation/shared/pages/splash_screen.dart
// Écran de démarrage avec vérification de session

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../core/di/providers.dart';
import '../../proprietaires/pages/auth_screens/owner_login_screen.dart';
import '../../proprietaires/pages/home_owner_screen.dart';
import '../../locataires/pages/home_tenant_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    // Écouter le résultat de la vérification d'authentification
    ref.listen<AsyncValue<AuthCheckResult>>(authStateProvider,
        (previous, next) {
      next.whenData((result) {
        _navigateToScreen(result);
      });
    });

    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Logo animé (texte uniquement)
              AnimatedBuilder(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nom de l'app avec la police du logo
                    Text(
                      'PayRent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: logoFontFamily,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentRed,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    Text(
                      'Gestion locative simplifiée',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.accentRed.withAlpha(180),
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Indicateur de chargement
              authState.when(
                loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentRed.withAlpha(200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: AppColors.accentRed.withAlpha(150),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                error: (error, stack) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.accentRed.withAlpha(200),
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de connexion',
                      style: TextStyle(
                        color: AppColors.accentRed.withAlpha(150),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(authStateProvider);
                      },
                      child: Text(
                        'Réessayer',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                data: (_) => const SizedBox.shrink(),
              ),

              const Spacer(flex: 1),

              // Version de l'app
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: AppColors.accentRed.withAlpha(100),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fichier : lib/core/services/auth_state_service.dart
// Service pour gérer l'état d'authentification global

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_appwrite.dart';
import '../di/providers.dart';

/// États possibles de l'authentification
enum AuthStatus {
  initial,    // État initial, vérification en cours
  authenticated,   // Utilisateur connecté
  unauthenticated, // Utilisateur non connecté
}

/// État de l'authentification
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Controller pour gérer l'état d'authentification
class AuthStateController extends StateNotifier<AuthState> {
  final AuthRepositoryAppwrite _authRepository;

  AuthStateController(this._authRepository) : super(const AuthState()) {
    // Vérifier automatiquement si l'utilisateur est connecté au démarrage
    checkAuthStatus();
  }

  /// Vérifier si l'utilisateur est déjà connecté
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          return;
        }
      }
      
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Mettre à jour l'état après une connexion réussie
  void setAuthenticated(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Déconnecter l'utilisateur
  Future<void> logout() async {
    try {
      await _authRepository.ownerLogout();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur de déconnexion: $e',
      );
    }
  }
}

/// Provider pour l'état d'authentification global
final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider) as AuthRepositoryAppwrite;
  return AuthStateController(authRepository);
});

/// Provider pour savoir si l'utilisateur est connecté
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).status == AuthStatus.authenticated;
});

/// Provider pour l'utilisateur courant
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});

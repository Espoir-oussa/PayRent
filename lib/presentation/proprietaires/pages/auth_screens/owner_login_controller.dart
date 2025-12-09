// Fichier : lib/presentation/proprietaires/pages/auth_screens/owner_login_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/auth/owner_login_usecase.dart';
import 'owner_login_state.dart';

class OwnerLoginController extends StateNotifier<OwnerLoginState> {
  final OwnerLoginUseCase loginUseCase;

    OwnerLoginController({required this.loginUseCase})
      : super(OwnerLoginState());

  // Méthode de connexion appelée par l'interface utilisateur
  Future<void> login({required String email, required String password}) async {
    // 1. Début du chargement
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      // 2. Exécution du cas d'utilisation (appel API)
      final userEntity = await loginUseCase(email: email, password: password);

      // 3. Succès
      state = state.copyWith(
        status: AuthStatus.success,
        // Enregistrez le token (ou l'entité) si nécessaire. 
        // Ici, on utilise l'ID de l'utilisateur comme token simulé.
        authToken: userEntity.idUtilisateur.toString(), 
      );
    } catch (e) {
      // 4. Échec
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Erreur de connexion: Mot de passe ou email incorrect.',
      );
    }
  }
  
  // Méthode pour réinitialiser l'état (utile après une déconnexion)
  void resetState() {
    state = OwnerLoginState();
  }
}
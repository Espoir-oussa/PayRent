// Fichier : lib/core/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../presentation/proprietaires/pages/auth_screens/owner_login_controller.dart';
import '../../presentation/proprietaires/pages/auth_screens/owner_login_state.dart';

// --- Imports des COUCHES ---
// 1. Core
import '../services/api_service.dart';

// 2. Data
import '../../data/repositories/plainte_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';



// 3. Domain
import '../../domain/repositories/plainte_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/plaintes/update_complaint_status_usecase.dart';
import '../../domain/usecases/auth/owner_login_usecase.dart';


// =================================================================
// 1. PROVIDERS DE BASE (CORE)
// =================================================================

// Provider du service API
final apiServiceProvider = Provider((ref) {
  // Si vous gérez un token JWT, vous le récupérerez ici (ex: via SharedPreferences)
  // Pour l'instant, on démarre sans token.
  return ApiService();
});

// =================================================================
// 2. PROVIDERS DES REPOSITORIES (DATA)
// =================================================================

// Fournit l'implémentation concrète (PlainteRepositoryImpl) de l'interface (PlainteRepository)
final plainteRepositoryProvider = Provider<PlainteRepository>((ref) {
  return PlainteRepositoryImpl(ref.watch(apiServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiServiceProvider));
});


// =================================================================
// 3. PROVIDERS DES CAS D'UTILISATION (DOMAIN)
// =================================================================

// Use Case de la Plainte (dépend de PlainteRepository)
final updateComplaintStatusUseCaseProvider = Provider((ref) {
  return UpdateComplaintStatusUseCase(ref.watch(plainteRepositoryProvider));
});


// Use Case du Login Propriétaire (dépend d'AuthRepository)
final ownerLoginUseCaseProvider = Provider((ref) {
  return OwnerLoginUseCase(ref.watch(authRepositoryProvider));
});


// =================================================================
// 4. PROVIDERS DE GESTION D'ÉTAT (BLOC/CUBIT/Notifier) - Exemple
// =================================================================

// Ceci est l'étape suivante, où vous connecterez les Use Cases à l'UI
// Par exemple, pour l'écran de Login :

final ownerLoginControllerProvider = StateNotifierProvider<OwnerLoginController, OwnerLoginState>((ref) {
  return OwnerLoginController(
    loginUseCase: ref.watch(ownerLoginUseCaseProvider),
  );
});

// Fichier : lib/core/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_cache.dart';
import 'dart:convert';

import '../../presentation/proprietaires/controllers/owner_login_controller.dart';
import '../../presentation/proprietaires/states/owner_login_state.dart';
import '../../presentation/proprietaires/controllers/owner_register_controller.dart';
import '../../presentation/proprietaires/states/owner_register_state.dart';

// --- Imports des COUCHES ---
// 1. Core
import '../services/api_service.dart';
import '../services/appwrite_service.dart';
import '../services/image_upload_service.dart';
import '../services/invitation_service.dart';
import '../services/password_reset_service.dart';

// 2. Data
import '../../data/repositories/plainte_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/auth_repository_appwrite.dart';
import '../../data/repositories/bien_repository_appwrite.dart';
import '../../data/repositories/contrat_repository_appwrite.dart';
import '../../data/repositories/paiement_repository_appwrite.dart';
import '../../data/repositories/plainte_repository_appwrite.dart';
import '../../data/repositories/facture_repository_appwrite.dart';
import '../../data/models/bien_model.dart';

// 3. Domain
import '../../domain/repositories/plainte_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/bien_repository.dart';
import '../../domain/repositories/contrat_repository.dart';
import '../../domain/repositories/paiement_repository.dart';
import '../../domain/repositories/facture_repository.dart';
import '../../domain/usecases/plaintes/update_complaint_status_usecase.dart';
import '../../domain/usecases/auth/owner_login_usecase.dart';
import '../../domain/usecases/auth/owner_register_usecase.dart';

// =================================================================
// 1. PROVIDERS DE BASE (CORE)
// =================================================================

// Provider du service API (Legacy - pour migration progressive)
final apiServiceProvider = Provider((ref) {
  return ApiService();
});

// Provider du service Appwrite
final appwriteServiceProvider = Provider((ref) {
  return AppwriteService();
});

// Provider du service d'upload d'images
final imageUploadServiceProvider = Provider((ref) {
  return ImageUploadService(ref.watch(appwriteServiceProvider));
});

// Provider du service d'invitations
final invitationServiceProvider = Provider((ref) {
  return InvitationService(ref.watch(appwriteServiceProvider));
});

// Provider du service de réinitialisation de mot de passe
final passwordResetServiceProvider = Provider((ref) {
  return PasswordResetService(ref.watch(appwriteServiceProvider));
});

// =================================================================
// 2. PROVIDERS DES REPOSITORIES (DATA)
// =================================================================

// Repository Auth avec Appwrite (type concret pour accès aux méthodes spécifiques)
final authRepositoryAppwriteProvider = Provider<AuthRepositoryAppwrite>((ref) {
  return AuthRepositoryAppwrite(ref.watch(appwriteServiceProvider));
});

// Repository Auth avec Appwrite (interface abstraite)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryAppwriteProvider);
});

// Repository Auth Legacy (ancien - pour compatibilité si besoin)
final authRepositoryLegacyProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiServiceProvider));
});

// Repository des Biens avec Appwrite
final bienRepositoryProvider = Provider<BienRepository>((ref) {
  return BienRepositoryAppwrite(ref.watch(appwriteServiceProvider));
});

// Repository des Contrats avec Appwrite
final contratRepositoryProvider = Provider<ContratRepository>((ref) {
  return ContratRepositoryAppwrite(ref.watch(appwriteServiceProvider));
});

// Repository des Paiements avec Appwrite
final paiementRepositoryProvider = Provider<PaiementRepository>((ref) {
  return PaiementRepositoryAppwrite(ref.watch(appwriteServiceProvider));
});

// Repository des Plaintes avec Appwrite
final plainteRepositoryProvider = Provider<PlainteRepository>((ref) {
  return PlainteRepositoryAppwrite(ref.watch(appwriteServiceProvider));
});

// Repository des Plaintes Legacy (pour compatibilité)
final plainteRepositoryLegacyProvider = Provider<PlainteRepository>((ref) {
  return PlainteRepositoryImpl(ref.watch(apiServiceProvider));
});

// Repository des Factures avec Appwrite
final factureRepositoryProvider = Provider<FactureRepository>((ref) {
  return FactureRepositoryAppwrite(ref.watch(appwriteServiceProvider));
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

final ownerRegisterUseCaseProvider = Provider((ref) {
  return OwnerRegisterUseCase(ref.watch(authRepositoryProvider));
});

// =================================================================
// 4. PROVIDERS DE GESTION D'ÉTAT (BLOC/CUBIT/Notifier)
// =================================================================

final ownerLoginControllerProvider =
    StateNotifierProvider<OwnerLoginController, OwnerLoginState>((ref) {
  return OwnerLoginController(
    loginUseCase: ref.watch(ownerLoginUseCaseProvider),
  );
});

final ownerRegisterControllerProvider =
    StateNotifierProvider<OwnerRegisterController, OwnerRegisterState>((ref) {
  return OwnerRegisterController(
    registerUseCase: ref.watch(ownerRegisterUseCaseProvider),
  );
});

// =================================================================
// 5. PROVIDERS POUR LES BIENS
// =================================================================

// Provider pour l'ID de l'utilisateur connecté
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final appwriteService = ref.watch(appwriteServiceProvider);
  final user = await appwriteService.getCurrentUser();
  return user?.$id;
});

// Provider pour récupérer les biens du propriétaire

final proprietaireBiensProvider =
    FutureProvider.autoDispose<List<BienModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return <BienModel>[];

  final bienRepository = ref.watch(bienRepositoryProvider);

  final cache = LocalCache<List<BienModel>>(
    cacheKey: 'proprietaire_biens_$userId',
    fetcher: () async => bienRepository.getBiensByProprietaire(userId),
    fromJson: (json) {
      final list = (json['data'] as List?) ?? [];
      return list
          .map((e) => BienModel.fromJson(e as Map<String, dynamic>))
          .toList();
    },
    toJson: (list) => {
      'data': list.map((e) => e.toJson()).toList(),
    },
    revalidateDuration: const Duration(minutes: 5),
  );

  return cache.getData();
});

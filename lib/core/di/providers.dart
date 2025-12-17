// Fichier : lib/core/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_cache.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
import '../services/notification_service.dart';

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
import '../../config/environment.dart';

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

// Provider du service de notifications
final notificationServiceProvider = Provider((ref) {
  final client = ref.watch(appwriteServiceProvider).client;
  return NotificationService(client);
});

// Provider du nombre de notifications non lues pour l'utilisateur courant
final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return 0;
  final notifService = ref.watch(notificationServiceProvider);
  return notifService.unreadCountForUser(userId);
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
  if (user == null) {
    debugPrint('🔐 currentUserIdProvider: USER NULL');
  } else {
    debugPrint('🔐 currentUserIdProvider: User ID = ${user.$id}');
  }
  return user?.$id;
});

// Provider global pour le rôle sélectionné
class SelectedRoleNotifier extends StateNotifier<String> {
  final Ref ref;
  SelectedRoleNotifier(this.ref) : super('proprietaire') {
    _init();
  }

  Future<void> _init() async {
    try {
      final current = await ref.read(authRepositoryAppwriteProvider).getCurrentUser();
      if (current != null && current.typeRole.isNotEmpty) {
        state = current.typeRole;
      }
    } catch (_) {}
  }

  void select(String newRole) {
    if (newRole == state) return;

    // Optimistic update: set state immediately so UI reacts fast
    state = newRole;

    // Persist in background (fire-and-forget)
    _persistRole(newRole);
  }

  Future<void> _persistRole(String newRole) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final current = await ref.read(authRepositoryAppwriteProvider).getCurrentUser();
      if (current == null) return;

      await appwriteService.updateDocument(
        collectionId: Environment.usersCollectionId,
        documentId: current.appwriteId ?? '',
        data: {'role': newRole, 'updatedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      // Optionnel: log ou revenir en arrière si nécessaire
    }
  }
}

final selectedRoleProvider = StateNotifierProvider<SelectedRoleNotifier, String>((ref) {
  return SelectedRoleNotifier(ref);
});

// =================================================================
// 6. PROVIDER PRINCIPAL - CACHE DÉSACTIVÉ POUR DEBUG
// =================================================================

final proprietaireBiensProvider =
    FutureProvider.autoDispose<List<BienModel>>((ref) async {
  debugPrint('🎯🎯🎯 DEBUT proprietaireBiensProvider 🎯🎯🎯');
  
  final userId = await ref.watch(currentUserIdProvider.future);
  
  if (userId == null) {
    debugPrint('❌❌❌ USER NULL - Retourne liste vide');
    return <BienModel>[];
  }

  debugPrint('🎯 Provider appelé pour USER: $userId');
  
  final bienRepository = ref.watch(bienRepositoryProvider);
  
  try {
    debugPrint('🔍 Appel à getBiensByProprietaire($userId)...');
    final biens = await bienRepository.getBiensByProprietaire(userId);
    
    debugPrint('📊 NOMBRE TOTAL DE BIENS REÇUS: ${biens.length}');
    
    // AFFICHER TOUS LES BIENS AVEC DÉTAILS
    if (biens.isEmpty) {
      debugPrint('📭 Liste vide - aucun bien trouvé');
    } else {
      for (var i = 0; i < biens.length; i++) {
        final bien = biens[i];
        final estAMoi = bien.proprietaireId == userId;
        final emoji = estAMoi ? '✅' : '🚨';
        debugPrint('   $emoji $i. ${bien.nom}');
        debugPrint('      proprietaireId: ${bien.proprietaireId}');
        debugPrint('      userId actuel: $userId');
        debugPrint('      Appartient à moi? $estAMoi');
      }
    }
    
    // FILTRAGE MANUEL ULTRA-STRICT
    final mesBiens = biens.where((bien) {
      final estAMoi = bien.proprietaireId == userId;
      if (!estAMoi) {
        debugPrint('💥💥💥 BIEN ÉTRANGER DÉTECTÉ ET FILTRÉ:');
        debugPrint('      Nom: ${bien.nom}');
        debugPrint('      proprietaireId: ${bien.proprietaireId}');
        debugPrint('      userId: $userId');
      }
      return estAMoi;
    }).toList();
    
    final nbEtrangers = biens.length - mesBiens.length;
    if (nbEtrangers > 0) {
      debugPrint('⚠️⚠️⚠️ ALERTE: $nbEtrangers BIEN(S) ÉTRANGER(S) FILTRÉ(S)!');
    }
    
    debugPrint('🎯 FIN Provider - Retourne ${mesBiens.length} biens');
    debugPrint('🎯🎯🎯 FIN proprietaireBiensProvider 🎯🎯🎯\n');
    
    return mesBiens;
    
  } catch (e) {
    debugPrint('❌❌❌ ERREUR dans provider: $e');
    debugPrint('❌❌❌ StackTrace: ${e.toString()}');
    return <BienModel>[];
  }
});

// =================================================================
// 7. PROVIDER SECOURS - UTILISE LES BIENS EXISTANTS
// =================================================================

final backupProprietaireBiensProvider = 
    FutureProvider.autoDispose<List<BienModel>>((ref) async {
  debugPrint('🔄🔄🔄 DEBUT backupProprietaireBiensProvider');
  
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return <BienModel>[];
  
  final bienRepository = ref.watch(bienRepositoryProvider);
  
  try {
    // Utilise searchBiens() pour récupérer TOUS les biens
    debugPrint('🔍 Appel à searchBiens() (tous les biens)...');
    final tousLesBiens = await bienRepository.searchBiens();
    
    debugPrint('📊 TOTAL BIENS DANS LA BASE: ${tousLesBiens.length}');
    
    // Filtrer manuellement
    final mesBiens = tousLesBiens.where((b) => b.proprietaireId == userId).toList();
    
    debugPrint('✅ Mes biens: ${mesBiens.length}');
    debugPrint('🚨 Biens des autres: ${tousLesBiens.length - mesBiens.length}');
    
    return mesBiens;
  } catch (e) {
    debugPrint('❌ Erreur backup: $e');
    return [];
  }
});
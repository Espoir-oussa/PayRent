// Fichier : lib/core/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // AJOUTER CET IMPORT
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
import '../services/auth_state_service.dart';

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
import '../../data/models/invitation_model.dart';
import '../../data/models/user_model.dart';

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

// Provider pour SharedPreferences (FutureProvider car c'est asynchrone)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// =================================================================
// 2. PROVIDERS POUR L'AUTHENTIFICATION ET UTILISATEUR COURANT
// =================================================================

// Provider de l'état d'authentification
final authStateProvider = StateNotifierProvider<AuthStateController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryAppwriteProvider);
  return AuthStateController(authRepository);
});

// Provider pour vérifier si l'utilisateur est connecté (basé sur authStateProvider)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).status == AuthStatus.authenticated;
});

// Provider pour l'utilisateur courant complet (basé sur authStateProvider)
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});

// Provider pour l'ID de l'utilisateur connecté (version simplifiée)
final currentUserIdProvider = Provider<String?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.appwriteId;
});

// Provider pour l'ID de l'utilisateur connecté (version FutureProvider)
final currentUserIdFutureProvider = FutureProvider<String?>((ref) async {
  final appwriteService = ref.watch(appwriteServiceProvider);
  try {
    final user = await appwriteService.getCurrentUser();
    return user?.$id;
  } catch (e) {
    debugPrint('❌ Erreur currentUserIdFutureProvider: $e');
    return null;
  }
});

// Provider pour l'ID utilisateur via SharedPreferences (cache local)
final cachedUserIdProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getString('user_id');
});

// =================================================================
// 3. PROVIDERS POUR LES NOTIFICATIONS ET INVITATIONS
// =================================================================

// Provider pour les invitations en attente du locataire connecté
final pendingInvitationsProvider = FutureProvider.autoDispose<List<InvitationModel>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    debugPrint('🔍 pendingInvitationsProvider: Utilisateur non connecté');
    return [];
  }

  final invitationService = ref.watch(invitationServiceProvider);
  
  try {
    debugPrint('🔍 Recherche invitations pour: ${currentUser.email}');
    final invitations = await invitationService.getPendingInvitationsByEmail(currentUser.email);
    
    debugPrint('📬 ${invitations.length} invitation(s) en attente trouvée(s)');
    
    // Filtrer les invitations expirées
    final validInvitations = invitations.where((inv) => inv.canBeAccepted).toList();
    
    if (validInvitations.length != invitations.length) {
      debugPrint('⚠️ ${invitations.length - validInvitations.length} invitation(s) expirée(s) filtrée(s)');
    }
    
    return validInvitations;
  } catch (e) {
    debugPrint('❌ Erreur récupération invitations: $e');
    return [];
  }
});

// Provider pour le nombre d'invitations en attente
final pendingInvitationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final invitations = await ref.watch(pendingInvitationsProvider.future);
  return invitations.length;
});

// Provider pour le nombre de notifications non lues pour l'utilisateur courant
final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = await ref.watch(currentUserIdFutureProvider.future);
  if (userId == null) {
    debugPrint('🔔 unreadNotificationsCountProvider: Pas d\'ID utilisateur');
    return 0;
  }
  
  try {
    final notifService = ref.watch(notificationServiceProvider);
    final count = await notifService.unreadCountForUser(userId);
    debugPrint('📊 Notifications non lues pour $userId: $count');
    return count;
  } catch (e) {
    debugPrint('❌ Erreur unreadNotificationsCountProvider: $e');
    return 0;
  }
});

// Provider pour le total notifications + invitations (pour l'appbar)
final totalNotificationsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final unreadNotifs = await ref.watch(unreadNotificationsCountProvider.future);
  final pendingInvit = await ref.watch(pendingInvitationsCountProvider.future);
  final total = unreadNotifs + pendingInvit;
  
  debugPrint('📊 Total notifications: $total (notifs: $unreadNotifs, invitations: $pendingInvit)');
  return total;
});

// Provider pour l'abonnement realtime des invitations
final invitationsRealtimeProvider = Provider.autoDispose((ref) {
  debugPrint('🔌 Démarrage abonnement realtime invitations');
  
  final appwrite = ref.watch(appwriteServiceProvider);
  final sub = appwrite.subscribeToCollection(Environment.invitationsCollectionId);

  final listener = sub.stream.listen((event) async {
    try {
      debugPrint('🔄 Événement realtime invitations détecté');
      // Invalider les providers d'invitations pour forcer le rafraîchissement
      ref.invalidate(pendingInvitationsProvider);
      ref.invalidate(pendingInvitationsCountProvider);
      ref.invalidate(totalNotificationsCountProvider);
    } catch (e) {
      debugPrint('❌ Erreur dans listener invitations: $e');
    }
  });

  ref.onDispose(() {
    debugPrint('🔌 Arrêt abonnement realtime invitations');
    listener.cancel();
    try {
      sub.close();
    } catch (e) {
      debugPrint('❌ Erreur fermeture subscription invitations: $e');
    }
  });

  return sub;
});

// Provider pour l'abonnement realtime des notifications
final notificationsRealtimeProvider = Provider.autoDispose((ref) {
  debugPrint('🔌 Démarrage abonnement realtime notifications');
  
  final appwrite = ref.watch(appwriteServiceProvider);
  final sub = appwrite.subscribeToCollection(Environment.notificationsCollectionId);

  final listener = sub.stream.listen((event) async {
    try {
      debugPrint('🔄 Événement realtime notifications détecté');
      // Invalider le provider de comptage
      ref.invalidate(unreadNotificationsCountProvider);
      ref.invalidate(totalNotificationsCountProvider);
    } catch (e) {
      debugPrint('❌ Erreur dans listener notifications: $e');
    }
  });

  ref.onDispose(() {
    debugPrint('🔌 Arrêt abonnement realtime notifications');
    listener.cancel();
    try {
      sub.close();
    } catch (e) {
      debugPrint('❌ Erreur fermeture subscription notifications: $e');
    }
  });

  return sub;
});

// =================================================================
// 4. PROVIDERS DES REPOSITORIES (DATA)
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
// 5. PROVIDERS DES CAS D'UTILISATION (DOMAIN)
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
// 6. PROVIDERS DE GESTION D'ÉTAT (BLOC/CUBIT/Notifier)
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
// 7. PROVIDERS POUR LE RÔLE
// =================================================================

// Provider global pour le rôle sélectionné
class SelectedRoleNotifier extends StateNotifier<String> {
  final Ref ref;
  SelectedRoleNotifier(this.ref) : super('proprietaire') {
    _init();
  }

  Future<void> _init() async {
    try {
      final current = ref.read(currentUserProvider);
      if (current != null && current.typeRole.isNotEmpty) {
        state = current.typeRole;
      }
    } catch (e) {
      debugPrint('❌ Erreur initialisation rôle: $e');
    }
  }

  void select(String newRole) {
    if (newRole == state) return;

    debugPrint('🔄 Changement de rôle: $state → $newRole');
    
    // Optimistic update: set state immediately so UI reacts fast
    state = newRole;

    // Persist in background (fire-and-forget)
    _persistRole(newRole);
  }

  Future<void> _persistRole(String newRole) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final current = ref.read(currentUserProvider);
      if (current == null) return;

      await appwriteService.updateDocument(
        collectionId: Environment.usersCollectionId,
        documentId: current.appwriteId ?? '',
        data: {'role': newRole, 'updatedAt': DateTime.now().toIso8601String()},
      );
      
      debugPrint('✅ Rôle $newRole persisté pour ${current.email}');
    } catch (e) {
      debugPrint('❌ Erreur persistance rôle: $e');
      // On pourrait revenir à l'ancien état ici si nécessaire
    }
  }
}

final selectedRoleProvider = StateNotifierProvider<SelectedRoleNotifier, String>((ref) {
  return SelectedRoleNotifier(ref);
});

// =================================================================
// 8. PROVIDER PRINCIPAL - BIENS DU PROPRIÉTAIRE
// =================================================================

final proprietaireBiensProvider =
    FutureProvider.autoDispose<List<BienModel>>((ref) async {
  debugPrint('🎯 DEBUT proprietaireBiensProvider');
  
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    debugPrint('❌ USER NULL - Retourne liste vide');
    return <BienModel>[];
  }

  debugPrint('🎯 Provider appelé pour USER: $userId');
  
  final bienRepository = ref.watch(bienRepositoryProvider);
  
  try {
    debugPrint('🔍 Appel à getBiensByProprietaire($userId)...');
    final biens = await bienRepository.getBiensByProprietaire(userId);
    
    debugPrint('📊 NOMBRE TOTAL DE BIENS REÇUS: ${biens.length}');
    
    // FILTRAGE MANUEL ULTRA-STRICT
    final mesBiens = biens.where((bien) => bien.proprietaireId == userId).toList();
    
    final nbEtrangers = biens.length - mesBiens.length;
    if (nbEtrangers > 0) {
      debugPrint('⚠️ ALERTE: $nbEtrangers BIEN(S) ÉTRANGER(S) FILTRÉ(S)!');
    }
    
    debugPrint('🎯 FIN Provider - Retourne ${mesBiens.length} biens');
    return mesBiens;
    
  } catch (e) {
    debugPrint('❌ ERREUR dans provider: $e');
    return <BienModel>[];
  }
});

// =================================================================
// 9. PROVIDER SECOURS - UTILISE LES BIENS EXISTANTS
// =================================================================

final backupProprietaireBiensProvider = 
    FutureProvider.autoDispose<List<BienModel>>((ref) async {
  debugPrint('🔄 DEBUT backupProprietaireBiensProvider');
  
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return <BienModel>[];
  
  final bienRepository = ref.watch(bienRepositoryProvider);
  
  try {
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

// Ajoutez ce provider supplémentaire pour garantir le type String
final currentUserIdStringProvider = Provider<String?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId is String) {
    return userId;
  }
  return null;
});

// OU version non-nullable (avec vérification)
final currentUserIdNonNullProvider = Provider<String>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId is String && userId.isNotEmpty) {
    return userId;
  }
  throw Exception('Utilisateur non connecté');
});
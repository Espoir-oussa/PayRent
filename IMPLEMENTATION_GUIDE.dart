// ============================================================================
// 📚 GUIDE COMPLET : GESTION DES BIENS - IMPLÉMENTATION COMPLÈTE
// ============================================================================
// 
// Ce document explique la structure complète d'une fonctionnalité dans PayRent
// en utilisant Clean Architecture avec Riverpod.
// 
// ============================================================================

/**
 * 🏗️ ARCHITECTURE MISE EN PLACE
 * 
 * Voici le flux de données complet pour la gestion des biens :
 * 
 * ┌─────────────────────────────────────────────────────────────────────┐
 * │                    COUCHE PRÉSENTATION (UI)                          │
 * │                                                                      │
 * │  BienManagementScreen (ConsumerStatefulWidget)                      │
 * │    ├─ Observe : ref.watch(bienListControllerProvider)              │
 * │    ├─ Dispatch : ref.read(bienListControllerProvider.notifier)     │
 * │    └─ Affiche : BienListState + BienCard widgets                  │
 * │                                                                      │
 * └─────────────────────┬──────────────────────────────────────────────┘
 *                       │
 *                       ↓ Appelle
 * 
 * ┌─────────────────────────────────────────────────────────────────────┐
 * │              COUCHE GESTION D'ÉTAT (STATE MANAGEMENT)               │
 * │                                                                      │
 * │  BienManagementController (StateNotifier<BienListState>)            │
 * │    ├─ État : BienListState                                         │
 * │    ├─ Méthodes :                                                    │
 * │    │   ├─ loadBiens(idProprietaire) → Charge les biens            │
 * │    │   └─ resetState() → Réinitialise l'état                       │
 * │    └─ Provider : bienListControllerProvider                        │
 * │                                                                      │
 * └─────────────────────┬──────────────────────────────────────────────┘
 *                       │
 *                       ↓ Utilise
 * 
 * ┌─────────────────────────────────────────────────────────────────────┐
 * │                COUCHE MÉTIER (DOMAIN LOGIC)                        │
 * │                                                                      │
 * │  GetBienListUseCase                                                 │
 * │    ├─ call(idProprietaire) → Récupère les biens                   │
 * │    └─ Utilise : BienRepository                                     │
 * │                                                                      │
 * │  Provider : getBienListUseCaseProvider                             │
 * │                                                                      │
 * └─────────────────────┬──────────────────────────────────────────────┘
 *                       │
 *                       ↓ Implémente
 * 
 * ┌─────────────────────────────────────────────────────────────────────┐
 * │                    COUCHE DONNÉES (DATA LAYER)                      │
 * │                                                                      │
 * │  BienRepositoryImpl                                                  │
 * │    ├─ Méthodes :                                                    │
 * │    │   ├─ getBiensByProprietaire() → Appelle ApiService            │
 * │    │   ├─ getBienById()          → Récupère un bien                │
 * │    │   ├─ createBien()           → Crée un bien                    │
 * │    │   ├─ updateBien()           → Modifie un bien                 │
 * │    │   └─ deleteBien()           → Supprime un bien                │
 * │    ├─ Utilise : ApiService (HTTP client)                           │
 * │    ├─ Utilise : MockDataService (données de test)                 │
 * │    └─ Convertit : BienModel ↔ JSON ↔ API                          │
 * │                                                                      │
 * │  Provider : bienRepositoryProvider                                  │
 * │                                                                      │
 * └─────────────────────┬──────────────────────────────────────────────┘
 *                       │
 *                       ↓ Utilise
 * 
 * ┌─────────────────────────────────────────────────────────────────────┐
 * │                     SERVICES & MODÈLES                              │
 * │                                                                      │
 * │  ApiService                                                         │
 * │    ├─ get(endpoint)    → Requête GET HTTP                          │
 * │    ├─ post(endpoint)   → Requête POST HTTP                         │
 * │    ├─ put(endpoint)    → Requête PUT HTTP                          │
 * │    ├─ delete(endpoint) → Requête DELETE HTTP                       │
 * │    └─ _handleResponse()→ Gère les erreurs HTTP                     │
 * │                                                                      │
 * │  BienModel (extends BienEntity)                                     │
 * │    ├─ Champs : idBien, idProprietaire, adresseComplete, etc.      │
 * │    ├─ fromJson() → Convertit JSON → Objet Dart                     │
 * │    └─ toJson()  → Convertit Objet Dart → JSON                      │
 * │                                                                      │
 * │  MockDataService                                                    │
 * │    └─ getMockBiens() → Retourne des données fictives pour tester   │
 * │                                                                      │
 * └─────────────────────────────────────────────────────────────────────┘
 */

// ============================================================================
// 📝 FICHIERS CRÉÉS/MODIFIÉS
// ============================================================================
//
// DOMAIN LAYER :
// ├─ lib/domain/entities/bien_entity.dart
// │  ✅ BienEntity : Entité métier (base, immuable)
// │
// ├─ lib/domain/repositories/bien_repository.dart
// │  ✅ BienRepository : Interface/Contrat
// │
// └─ lib/domain/usecases/biens/get_bien_list_usecase.dart
//    ✅ GetBienListUseCase : Logique métier
//
// DATA LAYER :
// ├─ lib/data/models/bien_model.dart
// │  ✅ BienModel extends BienEntity
// │  ✅ Sérialisation (fromJson/toJson)
// │
// ├─ lib/data/repositories/bien_repository_impl.dart
// │  ✅ BienRepositoryImpl : Implémentation concrète
// │  ✅ Intégration avec MockDataService pour tests
// │
// CORE LAYER :
// ├─ lib/core/services/api_service.dart
// │  ✅ Ajouté méthode delete()
// │
// ├─ lib/core/services/mock_data_service.dart
// │  ✅ MockDataService : Données de test
// │
// ├─ lib/core/di/providers.dart
// │  ✅ bienRepositoryProvider
// │  ✅ getBienListUseCaseProvider
// │  ✅ bienListControllerProvider
// │
// PRESENTATION LAYER :
// ├─ lib/presentation/proprietaires/pages/bien_screens/bien_list_state.dart
// │  ✅ BienListState : État de la liste
// │  ✅ BienStatus enum
// │
// ├─ lib/presentation/proprietaires/pages/bien_screens/bien_management_controller.dart
// │  ✅ BienManagementController : StateNotifier
// │  ✅ Méthode loadBiens(idProprietaire)
// │
// ├─ lib/presentation/proprietaires/widgets/bien_card.dart
// │  ✅ BienCard : Widget réutilisable
// │  ✅ Affichage : Adresse, Loyer, Charges, Actions (Modifier/Supprimer)
// │
// └─ lib/presentation/proprietaires/pages/bien_management_screen.dart
//    ✅ BienManagementScreen : Écran principal
//    ✅ Affichage liste, détails, actions
//    ✅ Intégration Riverpod

// ============================================================================
// 🚀 COMMENT UTILISER (EXEMPLE D'INTÉGRATION DANS L'APP)
// ============================================================================
//
// 1. L'écran BienManagementScreen est déjà intégré dans HomeOwnerScreen
//
// 2. Quand l'utilisateur appuie sur l'onglet "Biens" :
//    - Le widget BienManagementScreen s'affiche
//    - initState() appelle _loadBiens()
//    - _loadBiens() dispatch un appel au controller
//    - Le controller exécute le Use Case
//    - Les données mockées s'affichent
//
// 3. Pour afficher un bien en détail :
//    - Appuyer sur une BienCard
//    - Affiche un BottomSheet avec tous les détails
//
// 4. Pour éditer/supprimer un bien :
//    - Appuyer sur les boutons Modifier/Supprimer
//    - Les dialogues s'ouvrent (implémentation TODO)

// ============================================================================
// 🔧 COMMENT PASSER AUX DONNÉES RÉELLES (BACKEND)
// ============================================================================
//
// Dans lib/data/repositories/bien_repository_impl.dart :
//
// AVANT (développement avec mock) :
// @override
// Future<List<BienEntity>> getBiensByProprietaire(int idProprietaire) async {
//   try {
//     // DÉVELOPPEMENT : Utiliser les données mockées
//     await Future.delayed(const Duration(milliseconds: 800));
//     return MockDataService.getMockBiens();
//     ...
//
// APRÈS (production avec backend) :
// @override
// Future<List<BienEntity>> getBiensByProprietaire(int idProprietaire) async {
//   try {
//     final response = await apiService.get('biens/proprietaire/$idProprietaire');
//     final biensList = (response as List)
//         .map((bien) => BienModel.fromJson(bien as Map<String, dynamic>))
//         .toList();
//     return biensList;
//     ...
//
// C'est tout ! Riverpod se charge du reste.

// ============================================================================
// 📚 PATTERN À RÉUTILISER POUR LES AUTRES FONCTIONNALITÉS
// ============================================================================
//
// Vous pouvez copier/coller cette architecture pour :
// 
// ✅ Gestion des Plaintes
// ✅ Historique des Paiements
// ✅ Facturation
// ✅ Gestion des Contrats
// ✅ Gestion des Locataires
//
// Les étapes sont toujours les mêmes :
//
// 1. Créer l'Entity dans domain/entities/
// 2. Créer le Repository (interface) dans domain/repositories/
// 3. Créer les UseCases dans domain/usecases/
// 4. Créer le Model dans data/models/ (extends Entity)
// 5. Créer l'implémentation du Repository dans data/repositories/
// 6. Créer les Providers dans core/di/providers.dart
// 7. Créer le State dans presentation/.../[feature]_state.dart
// 8. Créer le Controller dans presentation/.../[feature]_controller.dart
// 9. Créer les Widgets réutilisables dans presentation/common/widgets/
// 10. Créer la Screen dans presentation/proprietaires/pages/

// ============================================================================
// ✨ AVANTAGES DE CETTE ARCHITECTURE
// ============================================================================
//
// ✅ Clean Architecture : Séparation des responsabilités
// ✅ Dependency Injection : Avec Riverpod
// ✅ Testable : Chaque couche peut être testée indépendamment
// ✅ Maintenable : Code organisé et prévisible
// ✅ Réutilisable : Patterns applicables à toutes les fonctionnalités
// ✅ Scalable : Facile d'ajouter de nouvelles fonctionnalités
// ✅ Mockable : MockDataService permet le développement sans backend

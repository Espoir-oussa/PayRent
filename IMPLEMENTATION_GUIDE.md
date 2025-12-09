# 📚 GUIDE : Implémentation de la Gestion des Biens

## 🎯 Vue d'ensemble

Ce guide explique comment j'ai implémenté la **Gestion des Biens** en utilisant **Clean Architecture** avec **Riverpod**. Ce pattern doit être répliqué pour toutes les autres fonctionnalités du projet.

---

## 🏗️ Architecture Mise en Place

```
┌─────────────────────────────────────────────────────────┐
│         COUCHE PRÉSENTATION (Screens & Widgets)        │
├─────────────────────────────────────────────────────────┤
│  - BienManagementScreen (affichage & interactions)      │
│  - BienCard (widget réutilisable pour une fiche)        │
│  - BienListState (état & statuts)                       │
│  - BienManagementController (gestion d'état)            │
└───────────────────────┬─────────────────────────────────┘
                        │ Utilise
                        ↓
┌─────────────────────────────────────────────────────────┐
│         COUCHE MÉTIER (Logic & UseCases)               │
├─────────────────────────────────────────────────────────┤
│  - GetBienListUseCase (récupère les biens)             │
│  - BienRepository (interface/contrat)                   │
│  - BienEntity (modèle métier)                           │
└───────────────────────┬─────────────────────────────────┘
                        │ Utilise
                        ↓
┌─────────────────────────────────────────────────────────┐
│         COUCHE DONNÉES (Repositories & Models)         │
├─────────────────────────────────────────────────────────┤
│  - BienRepositoryImpl (implémentation concrète)         │
│  - BienModel (sérialisation JSON)                       │
│  - ApiService (requêtes HTTP)                           │
│  - MockDataService (données de test)                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 Fichiers Créés/Modifiés

### Domain Layer (Métier)
```
lib/domain/
├── entities/
│   └── bien_entity.dart ✅ (Amélioré avec getter loyerTotal)
├── repositories/
│   └── bien_repository.dart ✅ (Interface avec 5 méthodes)
└── usecases/
    └── biens/
        └── get_bien_list_usecase.dart ✅ (Nouveau)
```

### Data Layer (Données)
```
lib/data/
├── models/
│   └── bien_model.dart ✅ (Maintenant extends BienEntity)
└── repositories/
    └── bien_repository_impl.dart ✅ (Nouveau - avec MockData)
```

### Core Layer (Services)
```
lib/core/
├── services/
│   ├── api_service.dart ✅ (Ajouté méthode delete())
│   └── mock_data_service.dart ✅ (Nouveau - données fictives)
└── di/
    └── providers.dart ✅ (3 providers Riverpod ajoutés)
```

### Presentation Layer (UI)
```
lib/presentation/proprietaires/
├── pages/
│   ├── bien_management_screen.dart ✅ (Complète)
│   └── bien_screens/
│       ├── bien_list_state.dart ✅ (Déjà existant)
│       └── bien_management_controller.dart ✅ (Nouveau)
└── widgets/
    └── bien_card.dart ✅ (Nouveau - widget réutilisable)
```

---

## 🔄 Flux de Données

### Étape 1 : L'écran s'affiche
```dart
BienManagementScreen extends ConsumerStatefulWidget
  ├─ initState() appelle _loadBiens()
  └─ _loadBiens() dispatch : ref.read(bienListControllerProvider.notifier).loadBiens(1)
```

### Étape 2 : Le controller exécute le Use Case
```dart
BienManagementController extends StateNotifier<BienListState>
  ├─ state = loading
  ├─ exécute : await getBienListUseCase(idProprietaire)
  └─ state = success/failure
```

### Étape 3 : Le Use Case appelle le Repository
```dart
GetBienListUseCase
  └─ appelle : repository.getBiensByProprietaire(idProprietaire)
```

### Étape 4 : Le Repository récupère les données
```dart
BienRepositoryImpl
  ├─ appelle : apiService.get('biens/proprietaire/1')
  ├─ convertit : JSON → BienModel → BienEntity
  └─ retourne : List<BienEntity>
```

### Étape 5 : L'écran affiche les données
```dart
BienManagementScreen
  ├─ observe : ref.watch(bienListControllerProvider)
  ├─ mappe chaque bien → BienCard(bien: bien)
  └─ affiche dans une ListView
```

---

## ✨ Fonctionnalités Implémentées

### ✅ Affichage de la Liste
- Liste scrollable de tous les biens du propriétaire
- Chargement avec indicateur de progression
- Pull-to-refresh (glisser vers le bas pour actualiser)

### ✅ Fiche de Bien (BienCard)
Chaque bien affiche :
- Adresse complète
- Type de bien
- Loyer de base (en euros)
- Charges locatives
- Loyer total (calculé automatiquement)
- Boutons d'action (Modifier, Supprimer)

### ✅ Détails du Bien
- Cliquer sur une carte affiche un BottomSheet avec tous les détails
- Fermeture facile avec un bouton

### ✅ Gestion des Erreurs
- Message d'erreur clair si le chargement échoue
- Bouton "Réessayer" pour relancer
- État "Aucun bien" si la liste est vide

### ✅ État de Chargement
- 4 statuts différents : `initial`, `loading`, `success`, `failure`
- Transitoire transparent entre les états

---

## 🚀 Tester Maintenant

1. **Lancer l'app** (si pas déjà lancée)
   ```bash
   flutter run
   ```

2. **Naviguer vers l'onglet "Biens"** du HomeOwnerScreen

3. **Vous verrez :**
   - Une liste de 4 biens fictifs (données mockées)
   - Un délai de 0.8 secondes (simule un appel réseau)
   - Vous pouvez cliquer sur une fiche pour voir les détails

4. **Tester le pull-to-refresh :**
   - Glissez vers le bas pour actualiser

5. **Tester les actions :**
   - Cliquez sur "Modifier" ou "Supprimer" (affiche un message TODO pour l'instant)

---

## 🔧 Comment Passer aux Données Réelles (Backend)

### Actuellement : Données Mockées
```dart
// dans bien_repository_impl.dart
@override
Future<List<BienEntity>> getBiensByProprietaire(int idProprietaire) async {
  try {
    // DÉVELOPPEMENT : données mockées
    await Future.delayed(const Duration(milliseconds: 800));
    return MockDataService.getMockBiens();
    ...
```

### Changer pour : Données Réelles
```dart
@override
Future<List<BienEntity>> getBiensByProprietaire(int idProprietaire) async {
  try {
    // PRODUCTION : appel API réel
    final response = await apiService.get('biens/proprietaire/$idProprietaire');
    final biensList = (response as List)
        .map((bien) => BienModel.fromJson(bien as Map<String, dynamic>))
        .toList();
    return biensList;
    ...
```

**C'est tout !** Riverpod se charge automatiquement du reste.

---

## 🎓 Leçons Apprises - Pattern à Réutiliser

Ce pattern doit être répliqué pour **TOUTES** les autres fonctionnalités :

### ✅ Gestion des Plaintes
1. Créer `PlainteEntity`
2. Créer `PlainteRepository` (interface)
3. Créer `GetPlainstUseCases`
4. Créer `PlainteModel extends PlainteEntity`
5. Créer `PlainteRepositoryImpl`
6. Ajouter providers dans `providers.dart`
7. Créer `Plainte State & Controller`
8. Créer `PlainteCard` widget
9. Créer `ComplaintTrackingScreen` complète

### ✅ Historique des Paiements
Même pattern avec :
- `PaiementEntity`
- `GetPaymentHistoryUseCase`
- `PaymentHistoryScreen`
- `PaymentCard`

### ✅ Facturation
Même pattern avec :
- `FactureEntity`
- `GetInvoicesUseCase`
- `InvoicingScreen`
- `InvoiceCard`

---

## 💡 Bonnes Pratiques Appliquées

### 1. **Séparation des responsabilités**
- Chaque couche a UN rôle précis
- UI ne parle pas à l'API directement
- Services ne contiennent pas de logique métier

### 2. **Inversion de contrôle**
- Les dépendances viennent du constructeur
- Facile à tester avec des mocks

### 3. **État centralisé avec Riverpod**
- Un seul source de vérité
- Les widgets se reconstruisent automatiquement

### 4. **Réutilisabilité**
- `BienCard` peut être utilisée n'importe où
- `GetBienListUseCase` est indépendant de l'UI

### 5. **Maintenabilité**
- Code lisible et prévisible
- Facile de déboguer (chaque couche en isolation)
- Facile d'ajouter des features

---

## 📋 Todo List - Prochaines Étapes

### Court terme (À faire immédiatement)
- [ ] Implémenter écran de création de bien
- [ ] Implémenter écran d'édition de bien
- [ ] Connecter les boutons "Modifier" et "Supprimer"
- [ ] Ajouter validation des formulaires
- [ ] Afficher les locataires d'un bien

### Moyen terme
- [ ] Implémenter gestion des plaintes (même pattern)
- [ ] Implémenter historique des paiements
- [ ] Implémenter facturation
- [ ] Créer écrans pour locataires (mirror des propriétaires)

### Long terme
- [ ] Intégrer le vrai backend
- [ ] Ajouter tests unitaires (70% de couverture)
- [ ] Ajouter tests d'intégratio
- [ ] Optimiser les performances

---

## 🤝 Questions & Support

### Q : Comment ajouter un champ au bien ?
**R :** 
1. Ajouter dans `BienEntity` 
2. Ajouter dans `BienModel`
3. Ajouter dans `MockDataService`
4. Ajouter dans `BienCard` pour l'affichage

### Q : Comment rendre un bouton fonctionnel ?
**R :**
1. Ajouter un Use Case
2. Ajouter dans le Controller
3. Connecter le bouton au Controller
4. Le bouton va appeler la méthode du Controller

### Q : Comment passer les vrais ID des propriétaires ?
**R :**
1. Stocker l'ID du propriétaire connecté (après login)
2. Passer cet ID à `_loadBiens(idProprietaire)`
3. Utiliser SharedPreferences ou un Provider pour garder l'ID

---

## 📞 Ressources

- **Riverpod Docs** : https://riverpod.dev
- **Flutter Clean Architecture** : https://resocoder.com/flutter-clean-architecture
- **Dart Async/Await** : https://dart.dev/guides/libraries/async-await

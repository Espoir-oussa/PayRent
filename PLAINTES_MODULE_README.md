# 📝 Module de Gestion des Plaintes - Propriétaire

## Vue d'ensemble

Ce module permet au propriétaire de :
- ✅ Voir la liste complète de toutes les plaintes
- ✅ Consulter les détails de chaque plainte
- ✅ Répondre aux plaintes en changeant leur statut
- ✅ Accepter une plainte (statut "Résolue")
- ✅ Rejeter une plainte (statut "Fermée")

## Architecture Clean

Le module respecte l'architecture Clean avec les couches suivantes :

### 1. Domain Layer (Logique Métier)

#### Use Cases
- **`GetOwnerComplaintsUseCase`** (`lib/domain/usecases/plaintes/get_owner_complaints_usecase.dart`)
  - Récupère toutes les plaintes d'un propriétaire

- **`UpdateComplaintStatusUseCase`** (`lib/domain/usecases/plaintes/update_complaint_status_usecase.dart`)
  - Met à jour le statut d'une plainte
  - Valide que seuls les statuts autorisés peuvent être définis

#### Repositories (Interfaces)
- **`PlainteRepository`** (`lib/domain/repositories/plainte_repository.dart`)
  - Interface définissant les opérations sur les plaintes

#### Entities
- **`PlainteEntity`** (`lib/domain/entities/plainte_entity.dart`)
  - Entité métier représentant une plainte

### 2. Data Layer (Accès aux Données)

#### Repositories (Implémentation)
- **`PlainteRepositoryImpl`** (`lib/data/repositories/plainte_repository_impl.dart`)
  - Implémentation concrète de l'interface PlainteRepository
  - Gère les appels API via ApiService

#### Models
- **`PlainteModel`** (`lib/data/models/plainte_model.dart`)
  - Modèle de données avec conversion JSON

### 3. Presentation Layer (Interface Utilisateur)

#### État et Contrôleur
- **`ComplaintTrackingState`** (`lib/presentation/proprietaires/pages/complaint_screens/complaint_tracking_state.dart`)
  - Définit les états possibles : initial, loading, loaded, error
  - Contient la liste des plaintes et les messages d'erreur

- **`ComplaintTrackingController`** (`lib/presentation/proprietaires/pages/complaint_screens/complaint_tracking_controller.dart`)
  - StateNotifier qui gère l'état des plaintes
  - Méthodes : `loadComplaints()`, `updateComplaintStatus()`, `refreshComplaints()`

#### Écrans
- **`ComplaintTrackingScreen`** (`lib/presentation/proprietaires/pages/complaint_tracking_screen.dart`)
  - Écran principal affichant la liste des plaintes
  - Fonctionnalités :
    - Pull-to-refresh pour actualiser la liste
    - Carte pour chaque plainte avec statut coloré
    - Navigation vers les détails au clic

- **`ComplaintDetailScreen`** (`lib/presentation/proprietaires/pages/complaint_screens/complaint_detail_screen.dart`)
  - Écran de détails d'une plainte
  - Fonctionnalités :
    - Affichage complet des informations
    - Bouton "Modifier le statut" avec sélection dans un dialogue
    - Boutons rapides "Accepter" (→ Résolue) et "Rejeter" (→ Fermée)

### 4. Core (Injection de Dépendances)

- **`providers.dart`** (`lib/core/di/providers.dart`)
  - Configuration Riverpod pour tous les providers
  - `getOwnerComplaintsUseCaseProvider`
  - `updateComplaintStatusUseCaseProvider`
  - `complaintTrackingControllerProvider`

## Statuts des Plaintes

Le système gère 5 statuts différents :

1. **🟠 Ouverte** - Nouvelle plainte créée par le locataire
2. **🔵 Réception** - Le propriétaire a pris connaissance
3. **🟣 En Cours de Résolution** - Traitement en cours
4. **🟢 Résolue** - Problème résolu (Acceptée)
5. **⚫ Fermée** - Plainte fermée/rejetée

## Fonctionnalités Implémentées

### Liste des Plaintes
- Affichage de toutes les plaintes avec :
  - Sujet de la plainte
  - Statut avec code couleur
  - Extrait de la description
  - Date de création
  - ID du bien concerné
- Indicateur de nombre de plaintes
- Bouton de rafraîchissement
- Pull-to-refresh
- Gestion des états vides et d'erreur

### Détails d'une Plainte
- Informations complètes :
  - Numéro de plainte
  - Statut actuel
  - Date de création
  - Sujet
  - Description complète
  - ID du locataire
  - ID du bien
- Actions disponibles :
  - **Modifier le statut** : Dialogue avec sélection du nouveau statut
  - **Accepter** : Change directement le statut en "Résolue"
  - **Rejeter** : Change directement le statut en "Fermée"

## Intégration

Le module est intégré dans l'application via :

1. **Navigation** : Menu principal (HomeOwnerScreen)
   - Onglet "Plaintes" dans la bottom navigation

2. **Riverpod** : Tous les providers sont configurés dans `lib/core/di/providers.dart`

3. **Dependencies** : 
   - `flutter_riverpod: ^2.5.1` (déjà présent)
   - `intl: ^0.19.0` (ajouté pour le formatage des dates)

## Points Importants

### ⚠️ ID Propriétaire
Actuellement, l'ID du propriétaire est codé en dur (`_ownerId = 1`) dans `ComplaintTrackingScreen`.
**TODO** : Récupérer l'ID réel depuis le système d'authentification.

### 🔄 Actualisation Automatique
Lorsqu'une plainte est mise à jour dans l'écran de détails, la liste est automatiquement rafraîchie au retour.

### 🎨 Design
- Interface moderne avec Material Design
- Codes couleur pour différencier les statuts
- Icônes explicites pour chaque statut
- Animations et transitions fluides

## Usage

```dart
// Accès au controller depuis un widget Consumer
final state = ref.watch(complaintTrackingControllerProvider);

// Charger les plaintes
ref.read(complaintTrackingControllerProvider.notifier)
   .loadComplaints(ownerId);

// Mettre à jour le statut
ref.read(complaintTrackingControllerProvider.notifier)
   .updateComplaintStatus(
     plainteId: 123,
     newStatus: '4. Résolue',
     ownerId: ownerId,
   );
```

## Tests

Pour tester le module :

1. **Backend** : Assurez-vous que votre API expose :
   - `GET /proprietaires/{ownerId}/plaintes` - Liste des plaintes
   - `PUT /plaintes/{plainteId}/status` - Mise à jour du statut

2. **Frontend** :
   - Lancez l'application
   - Connectez-vous en tant que propriétaire
   - Accédez à l'onglet "Plaintes"
   - Testez la navigation et les mises à jour

## Fichiers Créés/Modifiés

### Nouveaux fichiers
- `lib/domain/usecases/plaintes/get_owner_complaints_usecase.dart`
- `lib/presentation/proprietaires/pages/complaint_screens/complaint_tracking_state.dart`
- `lib/presentation/proprietaires/pages/complaint_screens/complaint_tracking_controller.dart`
- `lib/presentation/proprietaires/pages/complaint_screens/complaint_detail_screen.dart`

### Fichiers modifiés
- `lib/core/di/providers.dart` - Ajout des providers
- `lib/presentation/proprietaires/pages/complaint_tracking_screen.dart` - Implémentation complète
- `lib/data/repositories/plainte_repository_impl.dart` - Nettoyage imports
- `pubspec.yaml` - Ajout du package `intl`

## ✅ Architecture Préservée

Le code implémenté **respecte entièrement** votre architecture existante :
- Séparation claire des couches (Domain, Data, Presentation)
- Utilisation de Riverpod pour l'injection de dépendances
- Pattern Repository
- Use Cases pour la logique métier
- StateNotifier pour la gestion d'état
- Aucune modification des fichiers existants non nécessaire

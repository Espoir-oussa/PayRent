# 📋 Fonctionnalité Plaintes - Implémentation Complète

## 🎯 Objectif
Permettre aux locataires de soumettre des plaintes et aux propriétaires de les consulter et de changer leur statut.

## ✅ Ce qui a été implémenté

### 1️⃣ Côté Locataire

#### **Création de plaintes**
- **Fichier**: `lib/presentation/locataires/pages/complaint_creation_screen.dart`
- **Fonctionnalités**:
  - Formulaire avec sujet (min 5 caractères) et description (min 20 caractères)
  - Validation des champs
  - Enregistrement dans Appwrite
  - Notification de succès/erreur
  - Statut initial: "Ouverte"

#### **Consultation des plaintes**
- **Fichier**: `lib/presentation/locataires/pages/home_tenant_screen.dart` (onglet Plaintes)
- **Fonctionnalités**:
  - Liste de toutes les plaintes du locataire
  - Affichage du sujet, description, statut et date
  - Code couleur par statut:
    - 🟠 Ouverte (orange)
    - 🔵 En cours (bleu)
    - 🟢 Résolue (vert)
    - ⚫ Fermée (gris)
  - Bouton "Nouvelle plainte"
  - État vide si aucune plainte

#### **Détails d'une plainte**
- **Fichier**: `lib/presentation/locataires/pages/complaint_screens/complaint_detail_screen.dart`
- **Fonctionnalités**:
  - Affichage complet de la plainte
  - Sujet, description, date
  - Informations: ID, Bien, Locataire, Propriétaire
  - Statut avec code couleur

### 2️⃣ Côté Propriétaire

#### **Suivi des plaintes**
- **Fichier**: `lib/presentation/proprietaires/pages/complaint_tracking_screen.dart`
- **Fonctionnalités**:
  - Liste de toutes les plaintes de ses biens
  - Filtres par statut: Toutes, Ouverte, En cours, Résolue, Fermée
  - Affichage: sujet, description, locataire, date, statut
  - Tap sur une carte pour voir les détails
  
#### **Gestion du statut**
- **Modal Bottom Sheet** au tap sur une plainte
- **Fonctionnalités**:
  - Détails complets de la plainte
  - Chips pour changer le statut
  - Statuts disponibles: Ouverte, En cours, Résolue, Fermée
  - Mise à jour en temps réel
  - Notification de succès/erreur

### 3️⃣ Couche Domain (Use Cases)

#### **CreateComplaintUseCase**
- **Fichier**: `lib/domain/usecases/plaintes/create_complaint_usecase.dart`
- Crée une nouvelle plainte dans Appwrite
- Retourne le PlainteModel créé

#### **GetTenantComplaintsUseCase**
- **Fichier**: `lib/domain/usecases/plaintes/get_tenant_complaints_usecase.dart`
- Récupère toutes les plaintes d'un locataire par son ID
- Gestion des erreurs avec retour de liste vide

### 4️⃣ Providers (Riverpod)

Ajoutés dans `lib/core/di/providers.dart`:
```dart
final createComplaintUseCaseProvider = Provider<CreateComplaintUseCase>((ref) {
  return CreateComplaintUseCase(ref.read(plainteRepositoryProvider));
});

final getTenantComplaintsUseCaseProvider = Provider<GetTenantComplaintsUseCase>((ref) {
  return GetTenantComplaintsUseCase(ref.read(plainteRepositoryProvider));
});
```

## 📊 Flux de données

### Création d'une plainte (Locataire)
```
Locataire (home_tenant_screen)
    ↓ Tap "Nouvelle plainte"
ComplaintCreationScreen
    ↓ Remplit formulaire et valide
CreateComplaintUseCase
    ↓ 
PlainteRepository.createPlainte()
    ↓
Appwrite Collection "Plaintes"
    ↓ Retour
Affichage SnackBar succès
    ↓
Retour home_tenant_screen (refresh)
```

### Consultation des plaintes (Locataire)
```
home_tenant_screen (onglet Plaintes)
    ↓ FutureBuilder
GetTenantComplaintsUseCase(locataireId)
    ↓
PlainteRepository.getPlaintesByLocataire()
    ↓
Appwrite Query (where idLocataire = X)
    ↓ Retour List<PlainteModel>
Affichage cards avec statuts colorés
```

### Gestion des plaintes (Propriétaire)
```
ComplaintTrackingScreen
    ↓ FutureBuilder
PlainteRepository.getPlaintesByProprietaire()
    ↓
Appwrite Query (where idProprietaireGestionnaire = X)
    ↓ Retour List<PlainteModel>
Affichage avec filtres
    ↓ Tap sur card
Modal Bottom Sheet
    ↓ Tap sur chip statut
UpdateComplaintStatusUseCase
    ↓
PlainteRepository.updateComplaintStatus()
    ↓
Appwrite Document Update
    ↓ Success
Refresh + Notification
```

## 🗂️ Structure des fichiers modifiés/créés

```
PayRent/
├── lib/
│   ├── core/
│   │   └── di/
│   │       └── providers.dart (✏️ modifié - ajout providers)
│   │
│   ├── domain/
│   │   └── usecases/
│   │       └── plaintes/
│   │           ├── create_complaint_usecase.dart (✨ créé)
│   │           ├── get_tenant_complaints_usecase.dart (✨ créé)
│   │           └── plaintes_usecases.dart (✏️ modifié - exports)
│   │
│   └── presentation/
│       ├── locataires/
│       │   └── pages/
│       │       ├── home_tenant_screen.dart (✏️ modifié - onglet Plaintes)
│       │       ├── complaint_creation_screen.dart (✨ créé)
│       │       └── complaint_screens/
│       │           └── complaint_detail_screen.dart (✏️ modifié)
│       │
│       └── proprietaires/
│           └── pages/
│               └── complaint_tracking_screen.dart (✏️ modifié - implémentation complète)
```

## 🧪 Tests à effectuer

### En tant que Locataire:
1. ✅ Se connecter en tant que locataire
2. ✅ Aller sur l'onglet "Plaintes"
3. ✅ Cliquer sur "Nouvelle plainte"
4. ✅ Remplir le formulaire (sujet + description)
5. ✅ Valider et vérifier la notification de succès
6. ✅ Retour à la liste et voir la nouvelle plainte avec statut "Ouverte"
7. ✅ Cliquer sur une plainte pour voir les détails

### En tant que Propriétaire:
1. ✅ Se connecter en tant que propriétaire
2. ✅ Aller sur "Suivi des Plaintes"
3. ✅ Voir les plaintes soumises par les locataires
4. ✅ Utiliser les filtres (Toutes, Ouverte, En cours, etc.)
5. ✅ Cliquer sur une plainte
6. ✅ Changer le statut (Ex: "Ouverte" → "En cours")
7. ✅ Vérifier la notification de succès
8. ✅ Retour et vérifier que le statut est mis à jour

### Bidirectionnel:
1. ✅ Locataire crée une plainte
2. ✅ Propriétaire la voit et change le statut à "Résolue"
3. ✅ Locataire retourne sur son onglet Plaintes
4. ✅ Vérifier que le statut est "Résolue" (vert)

## 🔧 Appwrite Collection "Plaintes"

### Champs requis:
- `idPlainte` (integer)
- `idLocataire` (string) - ID utilisateur du locataire
- `idBien` (integer) - ID du bien concerné
- `idProprietaireGestionnaire` (string) - ID utilisateur du propriétaire
- `dateCreation` (datetime)
- `sujet` (string)
- `description` (string)
- `statutPlainte` (string) - "Ouverte", "En cours", "Resolue", "Fermee"

### Index recommandés:
- `idLocataire` (pour requêtes locataire)
- `idProprietaireGestionnaire` (pour requêtes propriétaire)
- `statutPlainte` (pour filtres)

## 📝 Notes importantes

1. **Statuts de plaintes**: Respecter les valeurs exactes: "Ouverte", "En cours", "Resolue", "Fermee"
2. **Validation**: Sujet min 5 caractères, description min 20 caractères
3. **Gestion d'erreurs**: Try-catch sur tous les appels Appwrite
4. **UX**: Loading indicators, messages d'erreur clairs, codes couleur
5. **Architecture**: Clean Architecture respectée (Domain → Data → Presentation)
6. **State Management**: Riverpod avec Providers

## 🚀 Prochaines améliorations possibles

- [ ] Notifications push au changement de statut
- [ ] Upload de photos pour les plaintes
- [ ] Historique des changements de statut
- [ ] Commentaires entre locataire et propriétaire
- [ ] Priorités sur les plaintes (Basse, Moyenne, Haute)
- [ ] Statistiques pour le propriétaire

---

✅ **Fonctionnalité complète et opérationnelle !**

# 🎯 TÂCHES IMMÉDIATES - À FAIRE MAINTENANT

## ✅ Ce qui est déjà prêt

L'implémentation de la gestion des biens est **100% fonctionnelle** avec des données mockées.

Vous pouvez :
- ✅ Voir la liste des biens
- ✅ Voir les détails d'un bien
- ✅ Actualiser la liste (pull-to-refresh)
- ✅ Observer les états de chargement

---

## 🚀 Tâches à Faire (Niveau Facile → Difficile)

### 🟢 NIVEAU DÉBUTANT - Commencer Par Ici

#### Task 1 : Implémenter l'écran de création de bien (30 min)
**Fichier à créer** : `lib/presentation/proprietaires/pages/bien_screens/add_bien_screen.dart`

```dart
class AddBienScreen extends ConsumerStatefulWidget {
  const AddBienScreen({super.key});

  @override
  ConsumerState<AddBienScreen> createState() => _AddBienScreenState();
}

class _AddBienScreenState extends ConsumerState<AddBienScreen> {
  late TextEditingController _adresseController;
  late TextEditingController _loyerController;
  late TextEditingController _chargesController;
  late TextEditingController _typeController;

  // TODO : Formvalidation et appel au Use Case
}
```

**Ce qu'il faut faire :**
1. Créer 4 TextEditingController pour : adresse, loyer, charges, type
2. Ajouter un formulaire avec validation
3. Créer un Use Case `CreateBienUseCase`
4. Connecter le bouton "Créer" au controller
5. Retourner à la liste après création

---

#### Task 2 : Connecter le bouton FAB (20 min)
**Fichier à modifier** : `bien_management_screen.dart`

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    // TODO : Naviguer vers AddBienScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBienScreen()),
    );
  },
  ...
)
```

**Ce qu'il faut faire :**
1. Importer `AddBienScreen`
2. Remplacer le ScaffoldMessenger par une vraie navigation
3. Tester la navigation

---

#### Task 3 : Ajouter filtres à la liste des biens (25 min)
**Fichier à modifier** : `bien_management_screen.dart`

Ajouter ces filtres :
- 🔍 Recherche par adresse
- 💰 Filtrer par plage de loyer
- 🏠 Filtrer par type de bien

**Astuce** : Ajouter une SearchBar et des Chips au-dessus de la ListView

---

### 🟡 NIVEAU INTERMÉDIAIRE

#### Task 4 : Implémenter l'historique des paiements (1-2h)
**Suivre le pattern de Bien** :

1. Créer `PaymentEntity`
2. Créer `PaiementRepository` interface
3. Créer `GetPaymentHistoryUseCase`
4. Créer `PaymentModel extends PaiementEntity`
5. Créer `PaiementRepositoryImpl`
6. Ajouter providers dans `providers.dart`
7. Créer `PaymentHistoryState` et `PaymentHistoryController`
8. Créer `PaymentCard` widget
9. Implémenter `PaymentHistoryScreen`

**Utiliser** : `EXAMPLE_IMPLEMENTATION_TEMPLATE.dart` comme guide

---

#### Task 5 : Implémenter le suivi des plaintes (1-2h)
**Même pattern que Task 4** mais avec :

1. `ComplainteEntity`
2. `ComplainteRepository`
3. `UpdateComplaintStatusUseCase` (déjà partially créé)
4. `ComplainteModel`
5. `ComplainteRepositoryImpl`
6. `ComplaintTrackingState` et `Controller`
7. `ComplaintCard` avec statuts (Ouverte, Résolue, Fermée)
8. `ComplaintTrackingScreen`

**Bonus** : Afficher les badges de couleur selon le statut

---

### 🔴 NIVEAU AVANCÉ

#### Task 6 : Ajouter formulaire d'édition de bien (2-3h)
**Fichier à créer** : `lib/presentation/proprietaires/pages/bien_screens/edit_bien_screen.dart`

- Récupérer les données du bien sélectionné
- Pré-remplir les champs
- Créer Use Case `UpdateBienUseCase`
- Valider et envoyer les modifications
- Mettre à jour la liste après succès

---

#### Task 7 : Implémenter la suppression de bien (1-2h)
**Créer** : `DeleteBienUseCase`

- Ajouter dialog de confirmation
- Appeler le Use Case
- Mettre à jour la liste
- Afficher un message de succès

---

#### Task 8 : Créer les écrans pour les locataires (2-3h)

**Mirror des écrans propriétaires** :
- `TenantHomeScreen` (dashboard locataire)
- `TenantPaymentScreen` (effectuer un paiement)
- `TenantComplaintsScreen` (soumettre une plainte)
- `TenantInvoicesScreen` (voir les factures)

---

## 📊 Ordre Recommandé

### Semaine 1 (Frontend Basique)
- [ ] Task 1 : Créer écran d'ajout de bien
- [ ] Task 2 : Connecter bouton FAB
- [ ] Task 3 : Ajouter filtres à la liste

### Semaine 2 (Autres Features)
- [ ] Task 4 : Historique des paiements
- [ ] Task 5 : Suivi des plaintes

### Semaine 3 (Édition/Suppression)
- [ ] Task 6 : Édition de bien
- [ ] Task 7 : Suppression de bien

### Semaine 4 (Écrans Locataires)
- [ ] Task 8 : Écrans pour locataires

---

## 🛠️ Commandes Utiles

### Vérifier les erreurs
```bash
flutter analyze
```

### Formater le code
```bash
flutter format lib/
```

### Lancer l'app
```bash
flutter run
```

### Nettoyer et relancer
```bash
flutter clean && flutter pub get && flutter run
```

---

## 📚 Ressources Utiles

### Pour Task 1-3 : Formulaires Flutter
- https://flutter.dev/docs/cookbook/forms/text-input
- https://flutter.dev/docs/cookbook/forms/validation

### Pour Task 4-7 : Pattern Clean Architecture
- Voir `IMPLEMENTATION_GUIDE.md`
- Voir `EXAMPLE_IMPLEMENTATION_TEMPLATE.dart`

### Pour Riverpod
- https://riverpod.dev/docs/basics

---

## 💡 Conseils

### ✅ Avant de commencer une task
1. Lire le guide correspondant
2. Comprendre le pattern
3. Créer les fichiers dans l'ordre

### ✅ Pendant le développement
1. Tester après chaque changement
2. Utiliser `flutter analyze` pour les erreurs
3. Commenter le code > 20 lignes
4. Respecter le naming convention

### ✅ Après la task
1. Tester tous les cas (succès, erreur, chargement)
2. Commit avec message descriptif
3. Push vers la branche
4. Demander review

---

## 🎓 Matrice de Difficulté

| Task | Durée | Difficulté | Points |
|------|-------|-----------|--------|
| 1    | 30min | 🟢 Easy   | 100    |
| 2    | 20min | 🟢 Easy   | 50     |
| 3    | 25min | 🟡 Medium | 150    |
| 4    | 2h   | 🟡 Medium | 300    |
| 5    | 2h   | 🟡 Medium | 300    |
| 6    | 3h   | 🔴 Hard   | 500    |
| 7    | 2h   | 🔴 Hard   | 300    |
| 8    | 3h   | 🔴 Hard   | 500    |

**Total estimé : 14-15 heures pour complétude 100%**

---

## ❓ Questions & Aide

### Je suis bloqué
1. Vérifier les erreurs avec `flutter analyze`
2. Lire le guide `IMPLEMENTATION_GUIDE.md`
3. Regarder l'exemple dans `EXAMPLE_IMPLEMENTATION_TEMPLATE.dart`
4. Comparer avec l'implémentation existante de Bien

### Où trouver les fichiers ?
- Domain : `lib/domain/`
- Data : `lib/data/`
- Core : `lib/core/`
- Presentation : `lib/presentation/`

### Comment tester ?
- Utiliser les données mockées
- Ajouter des prints pour déboguer
- Utiliser le DevTools de Flutter

---

## 🎉 Bon Courage !

Vous avez maintenant une **architecture complète et fonctionnelle**.  
Continuez avec l'ordre recommandé et vous aurez une **app complète en 3-4 semaines** ! 🚀

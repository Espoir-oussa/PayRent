# 📝 COMMITS GIT - Comment Sauvegarder Votre Travail

## 🎯 Convention des Commits

Utilisez cette convention pour tous vos commits :

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types autorisés
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `refactor` : Refactorisation sans changement de fonctionnalité
- `style` : Formatage du code
- `docs` : Documentation
- `test` : Tests
- `chore` : Maintenance

### Exemples

```bash
# Nouvelle fonctionnalité
git commit -m "feat(bien): add create bien screen and use case"

# Correction
git commit -m "fix(bien): fix loyer total calculation"

# Documentation
git commit -m "docs: add implementation guide for entire project"

# Refactor
git commit -m "refactor(bien): extract bien card to reusable widget"
```

---

## 📋 Commits Déjà Effectués

Pour documenter ce qui a été fait aujourd'hui, utilisez :

```bash
git add -A

# Créer un commit complet
git commit -m "feat: implement bien management with clean architecture

- Add BienEntity with computed loyerTotal property
- Create BienRepository interface with CRUD operations
- Implement GetBienListUseCase for business logic
- Create BienModel extending BienEntity for serialization
- Implement BienRepositoryImpl with MockDataService
- Add ApiService delete() method for HTTP deletion
- Create BienManagementScreen with full UI (list, details, filters)
- Create BienCard reusable widget for bien display
- Implement BienManagementController with Riverpod StateNotifier
- Add BienListState with 4 statuses (initial, loading, success, failure)
- Add 3 Riverpod providers for dependency injection
- Create MockDataService with 4 sample properties
- Add comprehensive documentation guides

Architecture: Clean Architecture (3 layers) + Riverpod for state management
Features: List view, Details modal, Pull-to-refresh, Error handling, Empty state
Status: Fully functional with mock data, ready for real API integration"
```

---

## 🔄 Workflow Git Recommandé

### 1. Avant de commencer une tâche
```bash
# Mettre à jour votre branche locale
git checkout RasaneBranch
git pull origin RasaneBranch

# Créer une branche pour votre tâche
git checkout -b feat/add-bien-creation-screen
```

### 2. Pendant le développement
```bash
# Vérifier le statut
git status

# Ajouter vos fichiers
git add lib/

# Commit réguliers (2-3 fois par jour)
git commit -m "feat(bien): implement add bien form with validation"
```

### 3. Quand c'est prêt
```bash
# Push vers votre branche
git push origin feat/add-bien-creation-screen

# Créer une Pull Request sur GitHub
# Demander review à un coéquipier
```

### 4. Merger dans main
```bash
# Après approval
git checkout RasaneBranch
git pull origin RasaneBranch
git merge feat/add-bien-creation-screen
git push origin RasaneBranch

# Supprimer la branche locale
git branch -d feat/add-bien-creation-screen
```

---

## 📊 Exemple de Commits pour les Tâches

### Task 1 : Créer écran d'ajout
```bash
git commit -m "feat(bien): create add bien screen with form

- Add AddBienScreen ConsumerStatefulWidget
- Implement form with 4 fields (address, rent, charges, type)
- Add form validation for all fields
- Create CreateBienUseCase in domain/usecases
- Connect form submission to controller
- Navigate back to list after successful creation
- Add error handling and loading state"
```

### Task 2 : Connecter FAB
```bash
git commit -m "feat(bien): connect FAB to add bien screen

- Replace ScaffoldMessenger with actual navigation
- Navigate to AddBienScreen on FAB tap
- Test navigation flow
- Update BienCard buttons to navigate to EditBienScreen"
```

### Task 3 : Ajouter filtres
```bash
git commit -m "feat(bien): add filters and search to bien list

- Add SearchBar widget for address search
- Add Chips for filtering by type
- Add RangeSlider for loyer filtering
- Update BienListState with filter criteria
- Implement filtering logic in controller"
```

### Task 4 : Historique paiements
```bash
git commit -m "feat(payment): implement payment history screen

- Create PaymentEntity in domain/entities
- Create PaymentRepository interface
- Implement GetPaymentHistoryUseCase
- Create PaymentModel with serialization
- Implement PaymentRepositoryImpl
- Add PaymentHistoryState and Controller
- Create PaymentCard reusable widget
- Implement PaymentHistoryScreen with list and filters
- Add MockDataService for payment testing"
```

---

## ✅ Checklist Avant de Committer

- [ ] Code testé et fonctionnel
- [ ] `flutter analyze` sans erreurs critiques
- [ ] `flutter format lib/` appliqué
- [ ] Imports organisés (pas d'imports inutiles)
- [ ] Comments ajoutés sur code complexe (>20 lignes)
- [ ] Pas de hardcoded values (utiliser des constantes)
- [ ] Pas de print/debugPrint en production
- [ ] Tous les TODOs fermés ou documentés

---

## 🚀 Commandes Utiles

### Vérifier avant commit
```bash
# Analyser le code
flutter analyze

# Formater
flutter format lib/

# Tester
flutter test

# Vérifier les changements
git diff
```

### Commits avancés
```bash
# Ajouter sélectivement
git add lib/presentation/
git commit -m "feat: update presentation layer"

# Modifier le dernier commit
git commit --amend

# Rebase sur main (garder historique clean)
git rebase origin/RasaneBranch

# Voir l'historique
git log --oneline --graph --all
```

---

## 📌 Convention Utilisée dans le Projet

Pour **PayRent**, respectez :

1. **Branche de travail** : `feat/` ou `fix/` suivi du nom
2. **Message** : Impératif, concis, descriptif
3. **Scope** : Nom du domaine (bien, payment, complaint, etc.)
4. **Corps** : Lister les changements importants
5. **Footer** : Rajouter `Fixes #123` si issue liée

### Exemple pour le travail d'aujourd'hui
```
feat(bien): implement complete bien management with clean architecture

Implement the complete Bien Management feature with Clean Architecture pattern
and Riverpod for state management.

Changes:
- Domain Layer: BienEntity, BienRepository, GetBienListUseCase
- Data Layer: BienModel, BienRepositoryImpl, MockDataService
- Presentation Layer: BienManagementScreen, BienCard, Controller
- Core Layer: Updated ApiService, added Riverpod providers

Architecture:
- 3-layer Clean Architecture (Domain, Data, Presentation)
- Riverpod for dependency injection and state management
- Mock data service for development without backend

Features:
- List biens with pull-to-refresh
- View bien details in modal
- Error handling with retry
- Loading states
- Empty state UI

Status: Fully functional with mock data, ready for API integration

See: IMPLEMENTATION_GUIDE.md for detailed documentation
Fixes #15
```

---

## 🎯 Pushing et Pull Requests

### Faire une Pull Request
```bash
# Après avoir commité sur votre branche
git push origin feat/your-feature

# Sur GitHub
# 1. Cliquer sur "Compare & pull request"
# 2. Remplir le template PR
# 3. Demander review
```

### Template Pull Request (à créer sur GitHub)

```markdown
## Description
Brève description de ce qui est fait.

## Type de changement
- [ ] Bug fix
- [x] New feature
- [ ] Breaking change
- [ ] Documentation update

## Lié à
Fixes #issue_number

## Comment tester
Étapes pour tester la feature.

## Screenshots
Si applicable.

## Checklist
- [ ] Code testé localement
- [ ] Pas d'erreurs flutter analyze
- [ ] Documentation mise à jour
- [ ] Pas de code commenté à supprimer
```

---

## 🛠️ En Cas de Problème

### Vous avez fait une erreur
```bash
# Annuler le dernier commit (garder les fichiers)
git reset --soft HEAD~1

# Annuler le dernier commit (perdre les changements)
git reset --hard HEAD~1
```

### Conflit pendant merge
```bash
# Voir les conflits
git status

# Résoudre manuellement, puis
git add .
git commit -m "resolve merge conflicts"
```

### Vous avez pushé par erreur
```bash
# Si pas encore mergé, revenir en arrière
git revert HEAD
git push

# Ou force push (attention !)
git push origin --force-with-lease
```

---

## 📚 Ressources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://danielkummer.github.io/git-flow-cheatsheet/)
- [GitHub Guides](https://guides.github.com/)

---

## 💡 Bonnes Pratiques

✅ **Commits fréquents** : Petit et focalisé (1 feature = 1-3 commits)
✅ **Messages clairs** : Quelqu'un d'autre doit comprendre en lisant
✅ **Une branche par feature** : Facilite les reviews et merges
✅ **Rebase sur main** : Garder historique clean
✅ **Squash si nécessaire** : Regrouper commits avant merge

---

**Bon développement ! 🚀**

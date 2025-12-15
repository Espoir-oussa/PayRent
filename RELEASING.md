# Releasing APK (Automatisation)

Ce guide explique comment préparer et déclencher la publication automatique de l'APK via GitHub Actions.

## 1) Créer un Personal Access Token (PAT)
- Sur GitHub, ouvre `Settings` → `Developer settings` → `Personal access tokens` → `Tokens (classic)` → `Generate new token`.
- Donne un nom, une expiration et sélectionne le scope `repo` (au minimum). Si tu veux restreindre, choisis un compte qui a accès au dépôt `Espoir-oussa/payrent-releases`.
- Génère le token et copie-le en lieu sûr.

## 2) Ajouter le secret `GH_RELEASES_TOKEN` au dépôt
Option A — via l'interface web (recommandée):
- Va sur le dépôt (é.g. `Espoir-oussa/payrent`).
- `Settings` → `Secrets and variables` → `Actions` → `New repository secret`.
- Nom : `GH_RELEASES_TOKEN` ; Valeur : ton PAT ; Enregistre.

Option B — via `gh` (CLI) :
- Assure-toi d'être connecté (`gh auth login`).
- Puis :

```bash
# lit le token depuis un fichier local (recommandé)
echo "$(cat token.txt)" | gh secret set GH_RELEASES_TOKEN --repo Espoir-oussa/payrent
```

> Le token doit permettre de créer des releases et d'uploader des assets dans `Espoir-oussa/payrent-releases`.

## 3) Déclencher une release (tag Git)
Le workflow CI se lance sur les tags `v*` (ex. `v1.0.4`).

Exemples :

```bash
# création d'un tag annoté
git tag -a v1.0.4 -m "Release v1.0.4"
# pousser le tag
git push origin v1.0.4
# ou pousser tous les tags
git push --tags
```

Après push du tag, vérifie l'onglet `Actions` du dépôt pour suivre le build. Si tout va bien, le workflow :
- construit l'APK,
- met à jour `web_redirect/version.json` et le pousse sur `main`,
- crée (ou met à jour) la release sur `Espoir-oussa/payrent-releases` et y téléverse l'APK.

**Note sur la branche et le tag :**
- Il est recommandé de créer le tag sur la branche `main` à jour (merge tes PR depuis `sculptor` vers `main` puis `git checkout main` + `git pull`) pour garantir que le tag référence l'état public et testé du code. Tu peux aussi tagger un commit spécifique si nécessaire : `git tag -a v1.0.4 <commit_sha> -m "Release v1.0.4"`.

## 4) Vérification / Débogage
- Si le workflow échoue, consulte la page Actions → job → logs.
- Erreurs fréquentes : token manquant (`GH_RELEASES_TOKEN`), permissions insuffisantes du token, APK non trouvé (vérifier `flutter build apk`).

## 5) Rappels
- Le secret `GH_RELEASES_TOKEN` doit être généré avec un compte disposant de droits sur `Espoir-oussa/payrent-releases`.
- Pour tests locaux, utiliser `scripts/release.ps1` (Windows) si souhaité.

## Expiration et rotation du PAT
- **Pourquoi :** l'expiration limite la fenêtre d'attaque si un PAT fuit.
- **Impact :** si un PAT expire, les workflows utilisant `GH_RELEASES_TOKEN` échoueront (erreurs d'authentification). Il faut alors créer un nouveau PAT, mettre à jour le secret et relancer le workflow.
- **Recommandation :** choisir une durée 30–90 jours selon le niveau de sécurité souhaité. Avant expiration, génère un nouveau PAT, mets à jour `GH_RELEASES_TOKEN` (via l'interface ou `gh secret set`) et teste la pipeline.

---
Fichier ajouté : `RELEASING.md` (racine du dépôt). Si tu veux, j'ajoute aussi un bref paragraphe dans le `README.md` pointant vers ce guide.
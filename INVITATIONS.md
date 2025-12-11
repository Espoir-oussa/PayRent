# Invitations — Flux et Configuration (PayRent)

## Objectif
Mettre en place un flux sécurisé pour l'envoi d'invitations aux locataires avec un `connectionCode` (6 chiffres) permettant la création sécurisée d'un compte sans demander de mot de passe à l'avance.

## Résumé du flux
- Le propriétaire choisit un bien et envoie une invitation avec l'email du locataire.
- Le backend génère un `connectionCode` de 6 chiffres, envoie le code par email (via SMTP) et stocke uniquement le `connectionCodeHash` (SHA-256) et la date d'expiration `connectionCodeExpiry` dans la collection Appwrite `invitations`.
- Le locataire reçoit l'email, clique sur le lien ou ouvre l'app.
- Dans l'app, il entre le `connectionCode` et clique sur Valider.
- L'app vérifie le hash correspondant, s'il y a correspondance et le code n'est pas expiré, le compte Appwrite est créé (mot de passe temporaire = code) et l'utilisateur est connecté.
- Le code est marqué comme utilisé (`connectionCodeUsed = true`) et supprimé/invalidé pour éviter la réutilisation.

## Schéma Appwrite (Collections)
Assurez-vous que la collection `invitations` de Appwrite possède les champs suivants :
- `connectionCodeHash` (string) — facultatif. Contient le hash SHA-256 du code.
- `connectionCodeExpiry` (datetime) — facultatif. Date et heure d'expiration du code.
- `connectionCodeUsed` (boolean) — facultatif, default false. Indique si le code a été utilisé.

### Comment ajouter ces champs via la console Appwrite

1. Ouvrez la console Appwrite → **Database** → sélectionnez votre database → **Collections** → **invitations**.
2. Cliquez sur **Attributes** → **Add Attribute** et créez :
   - `connectionCodeHash` : **Text** (size: 256), Required: No
   - `connectionCodeExpiry` : **DateTime**, Required: No
   - `connectionCodeUsed` : **Boolean**, Required: No, Default: false

### Exemple d'ajout via l'API Appwrite (curl)
Remplacez `<APPWRITE-ENDPOINT>`, `<DATABASE_ID>`, `<COLLECTION_ID>` et `<PROJECT_ID>` selon votre configuration.

```bash
curl -X POST "https://<APPWRITE-ENDPOINT>/v1/databases/<DATABASE_ID>/collections/<COLLECTION_ID>/attributes/string" \
  -H "X-Appwrite-Project: <PROJECT_ID>" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Key: <YOUR_ADMIN_KEY>" \
  -d '{"key":"connectionCodeHash","size":256,"required":false,"array":false}'
```

```bash
curl -X POST "https://<APPWRITE-ENDPOINT>/v1/databases/<DATABASE_ID>/collections/<COLLECTION_ID>/attributes/datetime" \
  -H "X-Appwrite-Project: <PROJECT_ID>" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Key: <YOUR_ADMIN_KEY>" \
  -d '{"key":"connectionCodeExpiry","required":false,"array":false}'
```

```bash
curl -X POST "https://<APPWRITE-ENDPOINT>/v1/databases/<DATABASE_ID>/collections/<COLLECTION_ID>/attributes/boolean" \
  -H "X-Appwrite-Project: <PROJECT_ID>" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Key: <YOUR_ADMIN_KEY>" \
  -d '{"key":"connectionCodeUsed","required":false,"default":false,"array":false}'
```

> Attention : utilisez un token admin lors d'appels API. En production, contrôlez les accès avec soin.

### Recommandation politique : TTL
- Utilisez `codeExpiry` assez court (ex: 30 minutes) pour limiter la fenêtre d'attaque.
- Purgez automatiquement les `connectionCodeHash` des invitations expirées (via cron/Cloud Function si souhaité).

## Mise à jour côté code
- `lib/data/models/invitation_model.dart`
  - Contient désormais `connectionCodeHash`, `connectionCodeExpiry`, `connectionCodeUsed` et `toAppwriteWithHash()` pour sérialiser uniquement le hash et expiry.

- `lib/core/services/invitation_service.dart`
  - `createInvitation(...)` : génère un code 6 chiffres, calcule SHA-256, stocke le hash + expiry (30 mins par défaut) dans le document invitation, puis appelle `EmailService.sendInvitationEmail(...)` en fournissant le code en clair **uniquement** pour l'email.
  - `acceptInvitationWithCode(token, code)` : vérifie le code (compare hash), crée le compte Appwrite (mot de passe temporaire = code), crée le profil utilisateur, le contrat, marque l'invitation comme `accepted` et `connectionCodeUsed`.
  - Comportement si compte déjà existant : si `createAccount` échoue parce que le compte existe déjà, Appwrite envoie un email de récupération via `createRecovery(...)`.

- `lib/core/services/email_service.dart`
  - Envoie le `connectionCode` et l'expiration dans le corps HTML/textuel de l'email.

- `lib/presentation/locataires/pages/accept_invitation_screen.dart`
  - Affiche un champ de saisie du `connectionCode`.
  - Appel à `invitationService.acceptInvitationWithCode(...)` et affichage de messages d'erreur.

## Tests End-to-End (E2E)
1. Lancer l'app sur un émulateur ou appareil connecté :

```powershell
flutter pub get
flutter run -d <device-id>
```

2. Dans l'app (propriétaire) :
- Ouvrir un bien actif et cliquer sur `Inviter un locataire`.
- Remplir l'email et envoyer l'invitation.

3. Vérifier que l'email est reçu (si SMTP correctement configuré) et notez le `connectionCode` et le lien.

4. Sur le mobile/emulateur :
- Copier le lien deep link et ouvrir via `adb` (Android) :
  ```powershell
  adb shell am start -a android.intent.action.VIEW -d "payrent://accept-invitation?token=<TOKEN>&action=accept" <PACKAGE_NAME>
  ```
- Entrez le `connectionCode` dans le champ de l'écran d'acceptation.
- Validez. Vous devriez être connecté et le contrat créé.

5. Cas compte existant :
- Si un compte existe déjà pour cet email, la création échouera, l'utilisateur recevra un email de récupération et l'interface proposera de se connecter.

## Notes de sécurité et migration
- Ne stockez jamais le code en clair en DB : sauvegarder uniquement le hash.
- TTL court (30 minutes) et marquage `connectionCodeUsed` pour invalider l'usage multiple.
- Journaux : ne logguez pas le code en clair en production.
- Traitez les erreurs Appwrite et adaptez les messages d'erreur côté UI pour guider l'utilisateur.

## Prochaines étapes
- Optionnel : ajouter une Cloud Function/cron pour purger `connectionCodeHash` quand expired.
- Ajouter tests automatisés qui mockent l'envoi d'email et simulent le flux d'acceptation.

---

### Script d'automatisation
Des scripts PowerShell et bash sont fournis pour créer automatiquement les attributs dans Appwrite :
- `scripts/add_appwrite_invitations_fields.ps1` (Windows PowerShell)
- `scripts/add_appwrite_invitations_fields.sh` (bash / WSL)

Usage PowerShell :
```powershell
.\scripts\add_appwrite_invitations_fields.ps1 -Endpoint "https://fra.cloud.appwrite.io" -ProjectId "69393f23001c2e93607c" -DatabaseId "payrent_db" -CollectionId "invitations" -ApiKey "SCOPED_ADMIN_KEY"
```

Usage bash :
```bash
./scripts/add_appwrite_invitations_fields.sh "https://fra.cloud.appwrite.io" "69393f23001c2e93607c" "payrent_db" "invitations" "SCOPED_ADMIN_KEY"
```

Remplacez `SCOPED_ADMIN_KEY` par votre clé d'administration Appwrite. Veillez à la sécurité; ne la stockez pas en clair dans des scripts partagés.


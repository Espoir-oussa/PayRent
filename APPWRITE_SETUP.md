# Configuration Appwrite pour PayRent

## 🚀 Étapes de configuration dans la Console Appwrite

### 1. Créer la base de données

Dans la console Appwrite ([https://cloud.appwrite.io](https://cloud.appwrite.io)) :

1. Allez dans **Databases**
2. Cliquez sur **Create Database**
3. **Database ID** : `payrent_db`
4. **Name** : `PayRent Database`

### 2. Créer les collections

Pour chaque collection, créez les attributs suivants :

#### Collection `users`
| Attribut | Type | Requis | Taille |
|----------|------|--------|--------|
| email | String | ✅ | 255 |
| nom | String | ✅ | 100 |
| prenom | String | ✅ | 100 |
| telephone | String | ❌ | 20 |
| type_role | String | ✅ | 50 |
| date_creation | DateTime | ✅ | - |

#### Collection `biens`
| Attribut | Type | Requis | Taille |
|----------|------|--------|--------|
| id_proprietaire | String | ✅ | 36 |
| adresse_complete | String | ✅ | 500 |
| type_bien | String | ❌ | 100 |
| loyer_de_base | Double | ✅ | - |
| charges_locatives | Double | ❌ | - |
| image_path | String | ❌ | 255 |
| date_creation | DateTime | ✅ | - |

#### Collection `contrats`
| Attribut | Type | Requis | Taille |
|----------|------|--------|--------|
| id_locataire | String | ✅ | 36 |
| id_bien | String | ✅ | 36 |
| date_debut | DateTime | ✅ | - |
| date_fin_prevue | DateTime | ❌ | - |
| montant_total_mensuel | Double | ✅ | - |
| statut | String | ✅ | 50 |
| date_creation | DateTime | ✅ | - |

#### Collection `paiements`
| Attribut | Type | Requis | Taille |
|----------|------|--------|--------|
| id_contrat | String | ✅ | 36 |
| montant_paye | Double | ✅ | - |
| date_paiement | DateTime | ✅ | - |
| statut | String | ✅ | 50 |
| reference_transaction_fedapay | String | ❌ | 100 |
| methode_paiement | String | ❌ | 50 |
| mois_concerne | String | ❌ | 10 |
| date_creation | DateTime | ✅ | - |

#### Collection `plaintes`
| Attribut | Type | Requis | Taille |
|----------|------|--------|--------|
| id_locataire | String | ✅ | 36 |
| id_bien | String | ✅ | 36 |
| id_proprietaire_gestionnaire | String | ✅ | 36 |
| date_creation | DateTime | ✅ | - |
| sujet | String | ✅ | 200 |
| description | String | ✅ | 2000 |
| statut_plainte | String | ✅ | 50 |
| reponse | String | ❌ | 2000 |
| date_reponse | DateTime | ❌ | - |
| images_ids | String[] | ❌ | - |

#### Collection `factures`
| Attribut | Type | Requis | Taille |
|----------|------|--------|--------|
| id_paiement | String | ✅ | 36 |
| date_emission | DateTime | ✅ | - |
| chemin_fichier_pdf | String | ❌ | 255 |
| numero_facture | String | ❌ | 50 |
| montant | Double | ✅ | - |
| description | String | ❌ | 500 |

### 3. Créer les Buckets de stockage

1. Allez dans **Storage**
2. Créez les buckets suivants :

| Bucket ID | Nom | Extensions autorisées |
|-----------|-----|----------------------|
| `images` | Images | jpg, jpeg, png, gif, webp |
| `documents` | Documents | pdf, doc, docx |

### 4. Configurer les permissions

Pour chaque collection, configurez les permissions selon les besoins :

- **users** : Les utilisateurs peuvent lire/modifier leur propre profil
- **biens** : Les propriétaires peuvent CRUD leurs biens
- **contrats** : Propriétaires et locataires peuvent lire
- **paiements** : Locataires peuvent créer, tous peuvent lire
- **plaintes** : Locataires créent, propriétaires répondent
- **factures** : Lecture seule pour les utilisateurs concernés

### 5. Créer des index (optionnel mais recommandé)

Pour optimiser les requêtes, créez des index sur :
- `biens.id_proprietaire`
- `contrats.id_locataire`
- `contrats.id_bien`
- `paiements.id_contrat`
- `plaintes.id_proprietaire_gestionnaire`

## 📱 Configuration Flutter

La configuration est déjà faite dans `lib/config/environment.dart` :

```dart
class Environment {
  static const String appwriteProjectId = 'VOTRE_PROJECT_ID';
  static const String appwritePublicEndpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String databaseId = 'payrent_db';
  // ... collections et buckets
}
```

## ✅ Vérification

Pour vérifier que tout fonctionne :

1. Lancez l'application : `flutter run`
2. Essayez de créer un compte
3. Vérifiez dans la console Appwrite que l'utilisateur apparaît

## 🔧 Dépannage

### Erreur de connexion
- Vérifiez que l'ID du projet est correct
- Vérifiez que l'endpoint est correct (fra, nyc, etc.)

### Erreur 401 Unauthorized
- L'utilisateur n'est pas connecté
- Le token de session a expiré

### Erreur 404 Not Found
- La collection ou le document n'existe pas
- Vérifiez les IDs dans Environment

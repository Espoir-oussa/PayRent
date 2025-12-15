// Script de configuration Appwrite utilisant HTTP pur
// Usage: dart run scripts/setup_appwrite.dart

import 'dart:convert';
import 'dart:io';

// Configuration Appwrite
const String endpoint = 'https://fra.cloud.appwrite.io/v1';
const String projectId = '69393f23001c2e93607c';
const String apiKey =
    'standard_df8f7ff09e27f40fdf43c1507011a47c3694500491897d0ca5a9669db274d4592ea2d6e2faf42cd0988d9521406ce7dbd1c1aa3112600b8fd58abf517caa8f4d8c7c25cd07ce4c902313545b0d85ee204ea8b9b415198d5eecf90c35479c4d2fbcdea465166094efe3c017eb08c60af3e6b1daf35506c1b1626591c699445267';
const String databaseId = 'payrent_db';

// Collection IDs
const String usersCollection = 'users';
const String biensCollection = 'biens';
const String contratsCollection = 'contrats';
const String paiementsCollection = 'paiements';
const String plaintesCollection = 'plaintes';
const String facturesCollection = 'factures';
const String invitationsCollection = 'invitations';
const String notificationsCollection = 'notifications';

// Bucket IDs
const String imagesBucket = 'images';
const String documentsBucket = 'documents';

class AppwriteHttpClient {
  final HttpClient _client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$endpoint$path');
    HttpClientRequest request;

    switch (method.toUpperCase()) {
      case 'POST':
        request = await _client.postUrl(uri);
        break;
      case 'GET':
        request = await _client.getUrl(uri);
        break;
      case 'PUT':
        request = await _client.putUrl(uri);
        break;
      case 'DELETE':
        request = await _client.deleteUrl(uri);
        break;
      default:
        throw Exception('Méthode HTTP non supportée: $method');
    }

    request.headers.set('Content-Type', 'application/json');
    request.headers.set('X-Appwrite-Project', projectId);
    request.headers.set('X-Appwrite-Key', apiKey);

    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 400) {
      // 409 = already exists, we can ignore
      if (response.statusCode == 409) {
        print('  ⚠️  Déjà existant (ignoré)');
        return {'alreadyExists': true};
      }
      throw Exception(
          'Erreur HTTP ${response.statusCode}: $responseBody');
    }

    if (responseBody.isEmpty) {
      return {};
    }

    return jsonDecode(responseBody) as Map<String, dynamic>;
  }

  void close() {
    _client.close();
  }
}

Future<void> createCollection(
  AppwriteHttpClient client,
  String collectionId,
  String name,
) async {
  print('📁 Création de la collection: $name ($collectionId)');
  try {
    await client.request('POST', '/databases/$databaseId/collections', body: {
      'collectionId': collectionId,
      'name': name,
      'permissions': [
        'read("users")',
        'create("users")',
        'update("users")',
        'delete("users")',
      ],
      'documentSecurity': true,
    });
    print('  ✅ Collection créée');
  } catch (e) {
    print('  ❌ Erreur: $e');
  }
}

Future<void> createStringAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key,
  int size, {
  bool required = false,
  String? defaultValue,
}) async {
  print('  📝 Attribut string: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/string',
      body: {
        'key': key,
        'size': size,
        'required': required,
        if (defaultValue != null) 'default': defaultValue,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createEmailAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key, {
  bool required = false,
}) async {
  print('  📧 Attribut email: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/email',
      body: {
        'key': key,
        'required': required,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createIntegerAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key, {
  bool required = false,
  int? min,
  int? max,
  int? defaultValue,
}) async {
  print('  🔢 Attribut integer: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/integer',
      body: {
        'key': key,
        'required': required,
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        if (defaultValue != null) 'default': defaultValue,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createFloatAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key, {
  bool required = false,
  double? min,
  double? max,
  double? defaultValue,
}) async {
  print('  💰 Attribut float: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/float',
      body: {
        'key': key,
        'required': required,
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        if (defaultValue != null) 'default': defaultValue,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createBooleanAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key, {
  bool required = false,
  bool? defaultValue,
}) async {
  print('  ✓ Attribut boolean: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/boolean',
      body: {
        'key': key,
        'required': required,
        if (defaultValue != null) 'default': defaultValue,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createDatetimeAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key, {
  bool required = false,
}) async {
  print('  📅 Attribut datetime: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/datetime',
      body: {
        'key': key,
        'required': required,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createEnumAttribute(
  AppwriteHttpClient client,
  String collectionId,
  String key,
  List<String> elements, {
  bool required = false,
  String? defaultValue,
}) async {
  print('  📋 Attribut enum: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/attributes/enum',
      body: {
        'key': key,
        'elements': elements,
        'required': required,
        if (defaultValue != null) 'default': defaultValue,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createIndex(
  AppwriteHttpClient client,
  String collectionId,
  String key,
  String type,
  List<String> attributes, {
  List<String>? orders,
}) async {
  print('  🔍 Index: $key');
  try {
    await client.request(
      'POST',
      '/databases/$databaseId/collections/$collectionId/indexes',
      body: {
        'key': key,
        'type': type,
        'attributes': attributes,
        if (orders != null) 'orders': orders,
      },
    );
  } catch (e) {
    print('    ❌ Erreur: $e');
  }
}

Future<void> createBucket(
  AppwriteHttpClient client,
  String bucketId,
  String name, {
  int maxFileSize = 10 * 1024 * 1024, // 10MB
  List<String>? allowedExtensions,
}) async {
  print('🪣 Création du bucket: $name ($bucketId)');
  try {
    await client.request('POST', '/storage/buckets', body: {
      'bucketId': bucketId,
      'name': name,
      'permissions': [
        'read("users")',
        'create("users")',
        'update("users")',
        'delete("users")',
      ],
      'fileSecurity': true,
      'maximumFileSize': maxFileSize,
      if (allowedExtensions != null) 'allowedFileExtensions': allowedExtensions,
    });
    print('  ✅ Bucket créé');
  } catch (e) {
    print('  ❌ Erreur: $e');
  }
}

// ============== CONFIGURATION DES COLLECTIONS ==============

Future<void> setupUsersCollection(AppwriteHttpClient client) async {
  await createCollection(client, usersCollection, 'Users');
  await Future.delayed(Duration(milliseconds: 500));

  await createStringAttribute(client, usersCollection, 'nom', 100, required: true);
  await createStringAttribute(client, usersCollection, 'prenom', 100, required: true);
  await createEmailAttribute(client, usersCollection, 'email', required: true);
  await createStringAttribute(client, usersCollection, 'telephone', 20);
  await createEnumAttribute(client, usersCollection, 'role', ['proprietaire', 'locataire'], required: true);
  await createStringAttribute(client, usersCollection, 'adresse', 500);
  await createStringAttribute(client, usersCollection, 'photoUrl', 500);
  await createDatetimeAttribute(client, usersCollection, 'createdAt');
  await createDatetimeAttribute(client, usersCollection, 'updatedAt');

  await Future.delayed(Duration(seconds: 2));
  await createIndex(client, usersCollection, 'email_idx', 'unique', ['email']);
  await createIndex(client, usersCollection, 'role_idx', 'key', ['role']);
}

Future<void> setupBiensCollection(AppwriteHttpClient client) async {
  await createCollection(client, biensCollection, 'Biens');
  await Future.delayed(Duration(milliseconds: 500));

  await createStringAttribute(client, biensCollection, 'proprietaireId', 36, required: true);
  await createStringAttribute(client, biensCollection, 'nom', 200, required: true);
  await createStringAttribute(client, biensCollection, 'adresse', 500, required: true);
  await createEnumAttribute(client, biensCollection, 'type', ['appartement', 'maison', 'studio', 'villa', 'bureau', 'commerce', 'autre'], required: true);
  await createStringAttribute(client, biensCollection, 'description', 2000);
  await createFloatAttribute(client, biensCollection, 'surface');
  await createIntegerAttribute(client, biensCollection, 'nombrePieces');
  await createIntegerAttribute(client, biensCollection, 'nombreChambres');
  await createIntegerAttribute(client, biensCollection, 'nombreSallesDeBain');
  await createFloatAttribute(client, biensCollection, 'loyerMensuel', required: true);
  await createFloatAttribute(client, biensCollection, 'charges');
  await createFloatAttribute(client, biensCollection, 'caution');
  await createEnumAttribute(client, biensCollection, 'statut', ['disponible', 'occupe', 'en_travaux', 'indisponible'], defaultValue: 'disponible');
  await createStringAttribute(client, biensCollection, 'photosUrls', 5000); // JSON array as string
  await createStringAttribute(client, biensCollection, 'equipements', 2000); // JSON array as string
  await createDatetimeAttribute(client, biensCollection, 'createdAt');
  await createDatetimeAttribute(client, biensCollection, 'updatedAt');

  await Future.delayed(Duration(seconds: 3));
  await createIndex(client, biensCollection, 'proprietaire_idx', 'key', ['proprietaireId']);
  await createIndex(client, biensCollection, 'statut_idx', 'key', ['statut']);
  await createIndex(client, biensCollection, 'type_idx', 'key', ['type']);
}

Future<void> setupContratsCollection(AppwriteHttpClient client) async {
  await createCollection(client, contratsCollection, 'Contrats');
  await Future.delayed(Duration(milliseconds: 500));

  await createStringAttribute(client, contratsCollection, 'bienId', 36, required: true);
  await createStringAttribute(client, contratsCollection, 'locataireId', 36, required: true);
  await createStringAttribute(client, contratsCollection, 'proprietaireId', 36, required: true);
  await createDatetimeAttribute(client, contratsCollection, 'dateDebut');
  await createDatetimeAttribute(client, contratsCollection, 'dateFin');
  await createFloatAttribute(client, contratsCollection, 'loyerMensuel', required: true);
  await createFloatAttribute(client, contratsCollection, 'charges');
  await createFloatAttribute(client, contratsCollection, 'caution');
  await createIntegerAttribute(client, contratsCollection, 'jourPaiement', min: 1, max: 31, defaultValue: 1);
  await createEnumAttribute(client, contratsCollection, 'statut', ['actif', 'termine', 'resilie', 'en_attente'], defaultValue: 'en_attente');
  await createStringAttribute(client, contratsCollection, 'documentUrl', 500);
  await createStringAttribute(client, contratsCollection, 'notes', 2000);
  await createDatetimeAttribute(client, contratsCollection, 'createdAt');
  await createDatetimeAttribute(client, contratsCollection, 'updatedAt');

  await Future.delayed(Duration(seconds: 3));
  await createIndex(client, contratsCollection, 'bien_idx', 'key', ['bienId']);
  await createIndex(client, contratsCollection, 'locataire_idx', 'key', ['locataireId']);
  await createIndex(client, contratsCollection, 'proprietaire_idx', 'key', ['proprietaireId']);
  await createIndex(client, contratsCollection, 'statut_idx', 'key', ['statut']);
}

Future<void> setupPaiementsCollection(AppwriteHttpClient client) async {
  await createCollection(client, paiementsCollection, 'Paiements');
  await Future.delayed(Duration(milliseconds: 500));

  await createStringAttribute(client, paiementsCollection, 'contratId', 36, required: true);
  await createStringAttribute(client, paiementsCollection, 'locataireId', 36, required: true);
  await createStringAttribute(client, paiementsCollection, 'bienId', 36, required: true);
  await createFloatAttribute(client, paiementsCollection, 'montant', required: true);
  await createDatetimeAttribute(client, paiementsCollection, 'datePaiement');
  await createDatetimeAttribute(client, paiementsCollection, 'dateEcheance');
  await createEnumAttribute(client, paiementsCollection, 'statut', ['en_attente', 'paye', 'en_retard', 'partiel', 'annule'], defaultValue: 'en_attente');
  await createEnumAttribute(client, paiementsCollection, 'methodePaiement', ['especes', 'virement', 'cheque', 'carte', 'mobile_money', 'autre']);
  await createStringAttribute(client, paiementsCollection, 'reference', 100);
  await createStringAttribute(client, paiementsCollection, 'notes', 1000);
  await createStringAttribute(client, paiementsCollection, 'preuveUrl', 500);
  await createDatetimeAttribute(client, paiementsCollection, 'createdAt');
  await createDatetimeAttribute(client, paiementsCollection, 'updatedAt');

  await Future.delayed(Duration(seconds: 3));
  await createIndex(client, paiementsCollection, 'contrat_idx', 'key', ['contratId']);
  await createIndex(client, paiementsCollection, 'locataire_idx', 'key', ['locataireId']);
  await createIndex(client, paiementsCollection, 'bien_idx', 'key', ['bienId']);
  await createIndex(client, paiementsCollection, 'statut_idx', 'key', ['statut']);
  await createIndex(client, paiementsCollection, 'date_echeance_idx', 'key', ['dateEcheance']);
}

Future<void> setupPlaintesCollection(AppwriteHttpClient client) async {
  await createCollection(client, plaintesCollection, 'Plaintes');
  await Future.delayed(Duration(milliseconds: 500));

  await createStringAttribute(client, plaintesCollection, 'bienId', 36, required: true);
  await createStringAttribute(client, plaintesCollection, 'locataireId', 36, required: true);
  await createStringAttribute(client, plaintesCollection, 'proprietaireId', 36, required: true);
  await createStringAttribute(client, plaintesCollection, 'titre', 200, required: true);
  await createStringAttribute(client, plaintesCollection, 'description', 5000, required: true);
  await createEnumAttribute(client, plaintesCollection, 'categorie', ['plomberie', 'electricite', 'chauffage', 'serrurerie', 'nuisibles', 'humidite', 'bruit', 'autre'], required: true);
  await createEnumAttribute(client, plaintesCollection, 'priorite', ['basse', 'moyenne', 'haute', 'urgente'], defaultValue: 'moyenne');
  await createEnumAttribute(client, plaintesCollection, 'statut', ['ouverte', 'en_cours', 'resolue', 'fermee', 'annulee'], defaultValue: 'ouverte');
  await createStringAttribute(client, plaintesCollection, 'photosUrls', 2000);
  await createStringAttribute(client, plaintesCollection, 'reponse', 2000);
  await createDatetimeAttribute(client, plaintesCollection, 'dateResolution');
  await createDatetimeAttribute(client, plaintesCollection, 'createdAt');
  await createDatetimeAttribute(client, plaintesCollection, 'updatedAt');

  await Future.delayed(Duration(seconds: 3));
  await createIndex(client, plaintesCollection, 'bien_idx', 'key', ['bienId']);
  await createIndex(client, plaintesCollection, 'locataire_idx', 'key', ['locataireId']);
  await createIndex(client, plaintesCollection, 'proprietaire_idx', 'key', ['proprietaireId']);
  await createIndex(client, plaintesCollection, 'statut_idx', 'key', ['statut']);
  await createIndex(client, plaintesCollection, 'priorite_idx', 'key', ['priorite']);
}

Future<void> setupFacturesCollection(AppwriteHttpClient client) async {
  await createCollection(client, facturesCollection, 'Factures');
  await Future.delayed(Duration(milliseconds: 500));

  await createStringAttribute(client, facturesCollection, 'paiementId', 36, required: true);
  await createStringAttribute(client, facturesCollection, 'contratId', 36, required: true);
  await createStringAttribute(client, facturesCollection, 'locataireId', 36, required: true);
  await createStringAttribute(client, facturesCollection, 'proprietaireId', 36, required: true);
  await createStringAttribute(client, facturesCollection, 'numero', 50, required: true);
  await createFloatAttribute(client, facturesCollection, 'montantHT', required: true);
  await createFloatAttribute(client, facturesCollection, 'montantTVA');
  await createFloatAttribute(client, facturesCollection, 'montantTTC', required: true);
  await createDatetimeAttribute(client, facturesCollection, 'dateEmission');
  await createDatetimeAttribute(client, facturesCollection, 'dateEcheance');
  await createEnumAttribute(client, facturesCollection, 'statut', ['brouillon', 'emise', 'payee', 'annulee'], defaultValue: 'brouillon');
  await createStringAttribute(client, facturesCollection, 'description', 2000);
  await createStringAttribute(client, facturesCollection, 'pdfUrl', 500);
  await createDatetimeAttribute(client, facturesCollection, 'createdAt');
  await createDatetimeAttribute(client, facturesCollection, 'updatedAt');

  await Future.delayed(Duration(seconds: 3));
  await createIndex(client, facturesCollection, 'paiement_idx', 'key', ['paiementId']);
  await createIndex(client, facturesCollection, 'contrat_idx', 'key', ['contratId']);
  await createIndex(client, facturesCollection, 'locataire_idx', 'key', ['locataireId']);
  await createIndex(client, facturesCollection, 'proprietaire_idx', 'key', ['proprietaireId']);
  await createIndex(client, facturesCollection, 'numero_idx', 'unique', ['numero']);
  await createIndex(client, facturesCollection, 'statut_idx', 'key', ['statut']);
}

Future<void> setupInvitationsCollection(AppwriteHttpClient client) async {
  await createCollection(client, invitationsCollection, 'Invitations');
  await Future.delayed(Duration(milliseconds: 500));

  // Identifiants
  await createStringAttribute(client, invitationsCollection, 'bienId', 36, required: true);
  await createStringAttribute(client, invitationsCollection, 'bienNom', 200, required: true);
  await createStringAttribute(client, invitationsCollection, 'proprietaireId', 36, required: true);
  await createStringAttribute(client, invitationsCollection, 'proprietaireNom', 200, required: true);
  
  // Infos locataire
  await createStringAttribute(client, invitationsCollection, 'emailLocataire', 255, required: true);
  await createStringAttribute(client, invitationsCollection, 'nomLocataire', 100);
  await createStringAttribute(client, invitationsCollection, 'prenomLocataire', 100);
  await createStringAttribute(client, invitationsCollection, 'telephoneLocataire', 20);
  
  // Infos location
  await createFloatAttribute(client, invitationsCollection, 'loyerMensuel', required: true);
  await createFloatAttribute(client, invitationsCollection, 'charges');
  await createStringAttribute(client, invitationsCollection, 'message', 1000);
  
  // Statut et token
  await createEnumAttribute(client, invitationsCollection, 'statut', 
    ['pending', 'accepted', 'rejected', 'expired', 'cancelled'], 
    defaultValue: 'pending'
  );
  await createStringAttribute(client, invitationsCollection, 'token', 64, required: true);
  
  // Dates
  await createDatetimeAttribute(client, invitationsCollection, 'dateCreation');
  await createDatetimeAttribute(client, invitationsCollection, 'dateExpiration');

  await Future.delayed(Duration(seconds: 3));
  await createIndex(client, invitationsCollection, 'proprietaire_idx', 'key', ['proprietaireId']);
  await createIndex(client, invitationsCollection, 'bien_idx', 'key', ['bienId']);
  await createIndex(client, invitationsCollection, 'email_idx', 'key', ['emailLocataire']);
  await createIndex(client, invitationsCollection, 'token_idx', 'unique', ['token']);
  await createIndex(client, invitationsCollection, 'statut_idx', 'key', ['statut']);
}

Future<void> setupNotificationsCollection(AppwriteHttpClient client) async {
  await createCollection(client, notificationsCollection, 'Notifications');
  await Future.delayed(Duration(milliseconds: 400));

  await createStringAttribute(client, notificationsCollection, 'userId', 36, required: true);
  await createStringAttribute(client, notificationsCollection, 'title', 200, required: true);
  await createStringAttribute(client, notificationsCollection, 'body', 1000);
  await createStringAttribute(client, notificationsCollection, 'data', 2000);
  await createEnumAttribute(client, notificationsCollection, 'isRead', ['true', 'false'], required: true);
  await createDatetimeAttribute(client, notificationsCollection, 'createdAt');

  await Future.delayed(Duration(seconds: 1));
  await createIndex(client, notificationsCollection, 'user_idx', 'key', ['userId']);
}

// ============== MAIN ==============

Future<void> main() async {
  print('╔════════════════════════════════════════════════════════════════╗');
  print('║          🚀 Configuration Appwrite pour PayRent                ║');
  print('╠════════════════════════════════════════════════════════════════╣');
  print('║  Endpoint: $endpoint');
  print('║  Project:  $projectId');
  print('║  Database: $databaseId');
  print('╚════════════════════════════════════════════════════════════════╝');
  print('');

  final client = AppwriteHttpClient();

  try {
    // Créer les collections
    print('\n📦 CRÉATION DES COLLECTIONS\n');
    print('=' * 50);

    print('\n[1/7] Collection Users');
    await setupUsersCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[2/7] Collection Biens');
    await setupBiensCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[3/7] Collection Contrats');
    await setupContratsCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[4/7] Collection Paiements');
    await setupPaiementsCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[5/7] Collection Plaintes');
    await setupPlaintesCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[6/7] Collection Factures');
    await setupFacturesCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[7/8] Collection Invitations');
    await setupInvitationsCollection(client);
    await Future.delayed(Duration(seconds: 2));

    print('\n[8/8] Collection Notifications');
    await setupNotificationsCollection(client);
    await Future.delayed(Duration(seconds: 2));

    // Créer les buckets de stockage
    print('\n\n🗄️ CRÉATION DES BUCKETS DE STOCKAGE\n');
    print('=' * 50);

    await createBucket(
      client,
      imagesBucket,
      'Images',
      maxFileSize: 10 * 1024 * 1024,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );

    await createBucket(
      client,
      documentsBucket,
      'Documents',
      maxFileSize: 20 * 1024 * 1024,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    print('\n');
    print('╔════════════════════════════════════════════════════════════════╗');
    print('║         ✅ Configuration terminée avec succès!                 ║');
    print('╚════════════════════════════════════════════════════════════════╝');
    print('\n');
    print('📋 Résumé:');
    print('   • 6 collections créées avec leurs attributs et index');
    print('   • 2 buckets de stockage configurés');
    print('\n');
    print('🔗 Vérifiez dans la console Appwrite:');
    print('   $endpoint/console/project-$projectId/databases/database-$databaseId');
    print('\n');
  } catch (e) {
    print('\n❌ Erreur lors de la configuration: $e');
  } finally {
    client.close();
  }
}

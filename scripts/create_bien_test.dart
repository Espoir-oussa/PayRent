// Script: scripts/create_bien_test.dart
// Usage:
//   dart run scripts/create_bien_test.dart --userId=<USER_ID> [--cleanup] [--dry-run]
//
// Ce script crée un document de test dans la collection `biens` en envoyant
// explicitement des permissions du type `read("user:<id>")` et vérifie
// ensuite quelles permissions sont effectivement stockées par Appwrite.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'setup_appwrite.dart';

final client = AppwriteHttpClient();

String _randomId() {
  final r = Random.secure();
  final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
}

Future<void> main(List<String> args) async {
  final argMap = <String, String>{};
  for (final a in args) {
    if (a.startsWith('--') && a.contains('=')) {
      final p = a.substring(2).split('=');
      if (p.length == 2) argMap[p[0]] = p[1];
    }
  }

  final userId = argMap['userId'];
  final dryRun = args.contains('--dry-run');
  final cleanup = args.contains('--cleanup');

  if (userId == null || userId.isEmpty) {
    print('Usage: dart run scripts/create_bien_test.dart --userId=<USER_ID> [--cleanup] [--dry-run]');
    exit(1);
  }

  final docId = 'test_bien_${DateTime.now().millisecondsSinceEpoch}_${_randomId()}';

  final data = {
    'proprietaireId': userId,
    'nom': 'Test Bien ${DateTime.now().toIso8601String()}',
    'adresse': 'Adresse test',
    'type': 'appartement', // required enum
    'loyerMensuel': 1.0,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  final permsToSend = [
    'read("user:$userId")',
    'update("user:$userId")',
    'delete("user:$userId")',
  ];

  print('\n🔬 create_bien_test: userId=$userId docId=$docId');
  print('  🔐 permissions requested:');
  for (final p in permsToSend) print('    - $p');

  if (dryRun) {
    print('\n💡 Dry-run mode: no request will be sent.');
    return;
  }

  try {
    // Create document
    print('\n1) Création du document...');
    final createResp = await client.request('POST', '/databases/$databaseId/collections/$biensCollection/documents', body: {
      'documentId': docId,
      'data': data,
      'permissions': permsToSend,
    });

    print('  ✅ Création réponse: ${createResp.keys.join(', ')}');
    if (createResp.containsKey('permissions')) {
      print('  🔍 Permissions retournées par la création:');
      for (final p in (createResp['permissions'] as List<dynamic>).cast<String>()) {
        print('    - $p');
      }
    } else {
      print('  ⚠️ La réponse de création ne contient pas de champ `permissions`.');
    }

    // Fetch the document to verify stored permissions
    print('\n2) Récupération du document pour vérification...');
    final getResp = await client.request('GET', '/databases/$databaseId/collections/$biensCollection/documents/$docId');
    print('  ✅ Récupération: keys=${getResp.keys.join(', ')}');

    if (getResp.containsKey('permissions')) {
      print('  🔍 Permissions stockées:');
      for (final p in (getResp['permissions'] as List<dynamic>).cast<String>()) {
        print('    - $p');
      }
    } else {
      print('  ⚠️ L\'objet retourné par Appwrite ne contient pas le champ `permissions`.');
    }

    // Afficher le document entier (utile pour debug)
    print('\n🧾 Document: ${jsonEncode(getResp)}');

    if (cleanup) {
      print('\n3) Suppression du document de test (cleanup)...');
      try {
        await client.request('DELETE', '/databases/$databaseId/collections/$biensCollection/documents/$docId');
        print('  ✅ Document supprimé');
      } catch (e) {
        print('  ❌ Échec suppression: $e');
      }
    } else {
      print('\nℹ️ Le document de test reste présent (utilisez --cleanup pour le supprimer automatiquement).');
    }
  } catch (e) {
    print('  ❌ Erreur: $e');
  } finally {
    client.close();
  }
}

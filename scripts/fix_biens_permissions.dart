// Script: scripts/fix_biens_permissions.dart
// Usage:
//   dart run scripts/fix_biens_permissions.dart [--dry-run]
//
// Ce script met à jour UNIQUEMENT les *permissions de la collection* `biens` dans Appwrite
// sans modifier les documents existants.

import 'dart:convert';
import 'dart:io';

import 'setup_appwrite.dart';

final client = AppwriteHttpClient();

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final autoYes = args.contains('--yes') || args.contains('-y');
  print('\n🔧 Mise à jour des permissions de la collection `biens`');
  if (dryRun) print('  💡 Mode dry-run : aucune modification ne sera envoyée');
  if (autoYes) print('  ⚠️ Mode auto-confirm: les changements seront appliqués sans invite');

  try {
    print('\n1) Récupération de la collection `biens`...');
    final collection = await client.request('GET', '/databases/$databaseId/collections/$biensCollection');

    // Accept multiple possible keys for permissions returned by Appwrite
    final List<String> currentPerms = [];
    if (collection.containsKey('permissions')) {
      currentPerms.addAll(((collection['permissions']) as List<dynamic>).cast<String>());
    }
    if (collection.containsKey(r'$permissions')) {
      currentPerms.addAll(((collection[r'$permissions']) as List<dynamic>).cast<String>());
    }
    if (collection.containsKey('\$permissions')) {
      currentPerms.addAll(((collection['\$permissions']) as List<dynamic>).cast<String>());
    }

    // normalize unique
    final permsSet = currentPerms.toSet().toList();

    print('  ✅ Permissions actuelles:');
    for (final p in permsSet) print('    - $p');

    // Construire la nouvelle liste de permissions en remplaçant uniquement les patterns problématiques
    final List<String> newPerms = [];
    final readUsersRe = RegExp(r'read\([^\)]*users[^\)]*\)', caseSensitive: false);
    final updateUsersRe = RegExp(r'update\([^\)]*users[^\)]*\)', caseSensitive: false);
    final deleteUsersRe = RegExp(r'delete\([^\)]*users[^\)]*\)', caseSensitive: false);

    for (final p in permsSet) {
      final s = p.toString();
      if (readUsersRe.hasMatch(s) || updateUsersRe.hasMatch(s) || deleteUsersRe.hasMatch(s)) {
        // Removing collection-level read/update/delete for "users" to enforce document-level security.
        print('    ⚠️ Removing collection-level permissive entry: $s');
        continue; // skip adding it
      } else {
        // conserver les autres permissions intactes (ex: create("users"))
        if (!newPerms.contains(s)) newPerms.add(s);
      }
    }

    print('\n2) Permissions proposées:');
    for (final p in newPerms) print('    - $p');

    // Si aucune modification, sortir
    final setsEqual = _listEqualsIgnoreOrder(currentPerms.cast<String>(), newPerms);
    if (setsEqual) {
      print('\n✅ Aucune modification nécessaire — les permissions sont déjà correctes.');
      return;
    }

    if (dryRun) {
      print('\n🔍 Dry-run: fin (aucune requête PATCH envoyée).');
      return;
    }

    // Demander confirmation avant d'appliquer (sauf si autoYes)
    if (!autoYes) {
      stdout.write('\n⚠️  Voulez-vous appliquer ces modifications aux permissions de la collection `biens` ? (y/N) ');
      final answer = stdin.readLineSync()?.trim().toLowerCase();
      if (answer != 'y' && answer != 'yes') {
        print('Annulé par l\'utilisateur. Aucune modification envoyée.');
        return;
      }
    } else {
      print('\n⚠️ Auto-confirm enabled — applying changes');
    }

    print('\n3) Application des nouvelles permissions...');
    // Appwrite collection update uses PUT and requires name/collectionId
    final name = (collection['name'] as String?) ?? 'Biens';
    final collectionIdToSend = (collection[r'$id'] as String?) ?? biensCollection;

    await client.request('PUT', '/databases/$databaseId/collections/$biensCollection', body: {
      'collectionId': collectionIdToSend,
      'name': name,
      'permissions': newPerms,
      'documentSecurity': true,
    });

    print('  ✅ Permissions mises à jour avec succès.');
  } catch (e) {
    print('  ❌ Erreur: $e');
  } finally {
    client.close();
  }
}

bool _listEqualsIgnoreOrder(List<String> a, List<String> b) {
  final as = List<String>.from(a)..sort();
  final bs = List<String>.from(b)..sort();
  if (as.length != bs.length) return false;
  for (var i = 0; i < as.length; i++) {
    if (as[i] != bs[i]) return false;
  }
  return true;
}

// Script: scripts/fix_biens_documents_permissions.dart
// Usage:
//   dart run scripts/fix_biens_documents_permissions.dart [--dry-run]
//
// Ce script met à jour UNIQUEMENT les *permissions des documents* dans la collection `biens`.
// Il remplace les permissions globales (ex: read("users")) par des permissions par utilisateur
// (ex: read("user:{userId}")) en se basant sur le champ `proprietaireId` de chaque document.

import 'dart:convert';
import 'dart:io';

import 'setup_appwrite.dart';

final client = AppwriteHttpClient();

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  print('\n🔧 Correction des permissions des documents dans `biens`');
  if (dryRun) print('  💡 Mode dry-run : aucune modification ne sera envoyée');

  try {
    print('\n1) Récupération des documents `biens` (limite 1000)...');
    final resp = await client.request('GET', '/databases/$databaseId/collections/$biensCollection/documents?limit=1000');
    final documents = (resp['documents'] as List<dynamic>?) ?? [];
    print('  ✅ Documents récupérés: ${documents.length}');

    final List<Map<String, dynamic>> changes = [];

    for (final d in documents) {
      final doc = d as Map<String, dynamic>;
      final docId = doc['\$id'] as String;
      final proprietaireId = (doc['proprietaireId'] as String?)?.trim() ?? '';
      final perms = (doc['permissions'] as List<dynamic>?)?.cast<String>() ?? [];

      if (proprietaireId.isEmpty) {
        print('  ⚠️  $docId : proprietaireId manquant — saut');
        continue;
      }

      // Build new permissions by replacing global patterns with per-user ones
      final List<String> newPerms = [];
      for (final p in perms) {
        if (p.contains('read("users")') || p.contains('read("role:users")') || p.contains('read("role:users")')) {
          final candidate = 'read("user:$proprietaireId")';
          if (!newPerms.contains(candidate)) newPerms.add(candidate);
        } else if (p.contains('update("users")') || p.contains('update("role:users")')) {
          final candidate = 'update("user:$proprietaireId")';
          if (!newPerms.contains(candidate)) newPerms.add(candidate);
        } else if (p.contains('delete("users")') || p.contains('delete("role:users")')) {
          final candidate = 'delete("user:$proprietaireId")';
          if (!newPerms.contains(candidate)) newPerms.add(candidate);
        } else {
          if (!newPerms.contains(p)) newPerms.add(p);
        }
      }

      // If no changes, continue
      final equal = _listEqualsIgnoreOrder(perms, newPerms);
      if (equal) continue;

      print('\n  • $docId');
      print('    proprietaireId: $proprietaireId');
      print('    perms:');
      for (final p in perms) print('      - $p');
      print('    proposed:');
      for (final p in newPerms) print('      - $p');

      changes.add({'docId': docId, 'proprietaireId': proprietaireId, 'old': perms, 'new': newPerms});
    }

    print('\n🔎 Résumé: ${changes.length} document(s) à modifier');

    final reportFile = File('scripts/fix_biens_documents_permissions_report.json');
    reportFile.writeAsStringSync(jsonEncode({'timestamp': DateTime.now().toIso8601String(), 'changes': changes},),);
    print('Report sauvegardé en scripts/fix_biens_documents_permissions_report.json');

    if (changes.isEmpty) {
      print('✅ Aucune modification nécessaire.');
      return;
    }

    if (dryRun) {
      print('\n🔍 Dry-run: fin (aucune requête PATCH envoyée).');
      return;
    }

    stdout.write('\n⚠️  Appliquer les modifications aux ${changes.length} documents ? (y/N) ');
    final answer = stdin.readLineSync()?.trim().toLowerCase();
    if (answer != 'y' && answer != 'yes') {
      print('Annulé par l\'utilisateur. Aucune modification envoyée.');
      return;
    }

    // Apply changes
    int applied = 0;
    for (final c in changes) {
      final id = c['docId'] as String;
      final newPerm = (c['new'] as List).cast<String>();
      try {
        await client.request('PATCH', '/databases/$databaseId/collections/$biensCollection/documents/$id', body: {
          'permissions': newPerm,
        });
        applied++;
      } catch (e) {
        print('  ❌ Échec application sur $id : $e');
      }
    }

    print('\n✅ Application terminée. Documents modifiés: $applied');
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

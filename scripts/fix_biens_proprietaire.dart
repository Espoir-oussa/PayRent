// Script: scripts/fix_biens_proprietaire.dart
// Usage: dart run scripts/fix_biens_proprietaire.dart

import 'dart:convert';
import 'dart:io';

import 'setup_appwrite.dart';

final client = AppwriteHttpClient();

Future<void> main() async {
  print('\n🔎 Scan des biens pour détecter proprietaireId manquant/incorrect...\n');

  try {
    // Pagination simple: récupérer 1000 docs maximum (on peut itérer si nécessaire)
    final resp = await client.request('GET', '/databases/$databaseId/collections/$biensCollection/documents?limit=1000');

    final documents = (resp['documents'] as List<dynamic>? ?? []);
    print('Found ${documents.length} documents in "$biensCollection"');

    int fixed = 0;
    final List<Map<String, dynamic>> toReview = [];

    for (final doc in documents) {
      final docId = doc['\$id'] as String;
      final proprietaireId = (doc['proprietaireId'] as String?)?.trim() ?? '';
      final permissions = (doc['permissions'] as List<dynamic>?)?.cast<String>() ?? [];

      bool needsFix = proprietaireId.isEmpty;

      if (!needsFix) {
        // Vérifier si l'ID correspond à un utilisateur existant
        try {
          final userResp = await client.request('GET', '/databases/$databaseId/collections/$usersCollection/documents/$proprietaireId');
          // Si on obtient une erreur, on catchera et traitera
        } catch (e) {
          needsFix = true;
        }
      }

      if (needsFix) {
        // Tenter d'inférer à partir des permissions
        var inferred = _inferUserIdFromPermissions(permissions);
        var source = 'permissions';

        // Si pas trouvé, tenter d'inférer depuis contrats
        if (inferred == null) {
          inferred = await _inferFromContracts(docId);
          source = 'contracts';
        }

        // Si toujours pas trouvé, tenter depuis invitations
        if (inferred == null) {
          inferred = await _inferFromInvitations(docId);
          source = 'invitations';
        }

        if (inferred != null) {
          print('Fixing doc $docId -> proprietaireId = $inferred (from $source)');
          try {
            await client.request('PATCH', '/databases/$databaseId/collections/$biensCollection/documents/$docId', body: {
              'proprietaireId': inferred,
              'updatedAt': DateTime.now().toIso8601String(),
            });
            fixed++;
          } catch (e) {
            print('  ❌ Échec mise à jour $docId: $e');
            toReview.add({'docId': docId, 'reason': 'update_failed', 'permissions': permissions});
          }
        } else {
          print('  ⚠️ Could not infer owner for doc $docId; flagging for manual review and marking needsReview=true');
          try {
            await client.request('PATCH', '/databases/$databaseId/collections/$biensCollection/documents/$docId', body: {
              'needsReview': true,
              'updatedAt': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            print('   ❌ Failed to mark needsReview for $docId: $e');
          }
          toReview.add({'docId': docId, 'permissions': permissions});
        }
      }
    }

    print('\n✅ Scan terminé. Docs fixed: $fixed. Docs to review: ${toReview.length}');
    if (toReview.isNotEmpty) {
      final f = File('scripts/fix_biens_proprietaire_report.json');
      f.writeAsStringSync(jsonEncode({'timestamp': DateTime.now().toIso8601String(), 'toReview': toReview},),);
      print('Report saved to scripts/fix_biens_proprietaire_report.json');
    }
  } catch (e) {
    print('Erreur pendant le scan: $e');
  } finally {
    client.close();
  }
}

String? _inferUserIdFromPermissions(List<String> perms) {
  // Appwrite permissions may contain patterns like 'role:user:USERID' or 'user:USERID' or 'user(USERID)'
  for (final p in perms) {
    final s = p.toString();
    // try regex for user:ID
    final r1 = RegExp(r'user[:\(]"?([a-zA-Z0-9-]{10,})"?');
    final m1 = r1.firstMatch(s);
    if (m1 != null) return m1.group(1);

    final r2 = RegExp(r'user:([a-zA-Z0-9-]{10,})');
    final m2 = r2.firstMatch(s);
    if (m2 != null) return m2.group(1);

    final r3 = RegExp(r'Role.user\(([^)]+)\)');
    final m3 = r3.firstMatch(s);
    if (m3 != null) return m3.group(1);
  }
  return null;
}

Future<String?> _inferFromContracts(String bienId) async {
  try {
    final q = Uri.encodeQueryComponent('queries[]=equal(bienId,$bienId)');
    final resp = await client.request('GET', '/databases/$databaseId/collections/$contratsCollection/documents?$q');
    final docs = (resp['documents'] as List<dynamic>?) ?? [];
    if (docs.isNotEmpty) {
      final first = docs.first as Map<String, dynamic>;
      final pid = (first['proprietaireId'] as String?)?.trim();
      if (pid != null && pid.isNotEmpty) return pid;
    }
  } catch (e) {
    // ignore
  }
  return null;
}

Future<String?> _inferFromInvitations(String bienId) async {
  try {
    final q = Uri.encodeQueryComponent('queries[]=equal(bienId,$bienId)');
    final resp = await client.request('GET', '/databases/$databaseId/collections/$invitationsCollection/documents?$q');
    final docs = (resp['documents'] as List<dynamic>?) ?? [];
    if (docs.isNotEmpty) {
      final first = docs.first as Map<String, dynamic>;
      final pid = (first['proprietaireId'] as String?)?.trim();
      if (pid != null && pid.isNotEmpty) return pid;
    }
  } catch (e) {
    // ignore
  }
  return null;
}

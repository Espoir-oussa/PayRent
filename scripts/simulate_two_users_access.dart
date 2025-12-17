// Script: scripts/simulate_two_users_access.dart
// Usage: dart run scripts/simulate_two_users_access.dart
//
// 1) Crée deux utilisateurs temporaires (UserA, UserB)
// 2) UserA crée un bien (avec permissions only user:UserA)
// 3) UserB se connecte (session) et tente de lister les biens
// 4) Le script affiche si UserB voit ou non le bien créé par UserA
// 5) Cleanup: suppression du doc et des users

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'setup_appwrite.dart';

final adminClient = AppwriteHttpClient();

String _randomString(int n) {
  final r = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(n, (_) => chars[r.nextInt(chars.length)]).join();
}

Future<void> main() async {
  print('\n🔬 Simulation: UserA crée un bien, UserB tente de le lister');

  final userAEmail = 'testA_${_randomString(6)}@example.com';
  final userBEmail = 'testB_${_randomString(6)}@example.com';
  final pwd = 'Pwd12345!';

  String? userAId;
  String? userBId;
  String? docId;

  try {
    // 1) Créer User A
    print('\n1) Création de UserA: $userAEmail');
    final respA = await adminClient.request('POST', '/users', body: {
      'userId': 'unique()',
      'email': userAEmail,
      'password': pwd,
      'name': 'User A',
    });
    userAId = (respA[r'$id'] as String?) ?? (respA['\$id'] as String?);
    print('  ✅ UserA id: $userAId');

    // 2) Créer User B
    print('\n2) Création de UserB: $userBEmail');
    final respB = await adminClient.request('POST', '/users', body: {
      'userId': 'unique()',
      'email': userBEmail,
      'password': pwd,
      'name': 'User B',
    });
    userBId = (respB[r'$id'] as String?) ?? (respB['\$id'] as String?);
    print('  ✅ UserB id: $userBId');

    // 3) User A crée un bien
    docId = 'sim_bien_${DateTime.now().millisecondsSinceEpoch}_${_randomString(4)}';
    final data = {
      'proprietaireId': userAId,
      'nom': 'Sim Bien ${_randomString(4)}',
      'adresse': 'Adresse sim',
      'type': 'appartement',
      'loyerMensuel': 1.0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final perms = [
      'read("user:$userAId")',
      'update("user:$userAId")',
      'delete("user:$userAId")',
    ];

    print('\n3) Création du doc par UserA (via admin API en simulant permissions): docId=$docId');
    final createResp = await adminClient.request('POST', '/databases/$databaseId/collections/$biensCollection/documents', body: {
      'documentId': docId,
      'data': data,
      'permissions': perms,
    });
    print('  ✅ Créé: ${(createResp[r'$id'] ?? createResp['\$id'] ?? '<no-id>')}');

    // 4) User B se connecte et obtient cookie
    print('\n4) UserB: création de session (connexion)');
    final sessionCookie = await _createSessionForUser(userBEmail, pwd);
    if (sessionCookie == null) {
      print('  ❌ Impossible de créer une session pour UserB');
      return;
    }
    print('  ✅ Session cookie pour UserB obtenue');

    // 5) User B tente de lister les documents
    print('\n5) UserB: tentative de listing des biens');
    final listed = await _listDocumentsAsUser(sessionCookie);
    final ids = listed.map((d) => (d[r'$id'] as String?) ?? (d['\$id'] as String?) ?? '').toList();
    print('  🔎 Documents visibles par UserB: ${ids.length} (ids: $ids)');

    final visible = ids.contains(docId);
    if (visible) {
      print('\n⚠️ Résultat: UserB VOIT le bien créé par UserA -> problème de permissions');
    } else {
      print('\n✅ Résultat: UserB NE VOIT PAS le bien créé par UserA -> permissions OK');
    }

  } catch (e) {
    print('  ❌ Erreur: $e');
  } finally {
    // Cleanup
    print('\n🧹 Cleanup...');
    if (docId != null) {
      try {
        await adminClient.request('DELETE', '/databases/$databaseId/collections/$biensCollection/documents/$docId');
        print('  ✅ Doc deleted');
      } catch (e) {
        print('  ❌ Could not delete doc: $e');
      }
    }
    if (userAId != null) {
      try {
        await adminClient.request('DELETE', '/users/$userAId');
        print('  ✅ UserA deleted');
      } catch (e) {
        print('  ❌ Could not delete userA: $e');
      }
    }
    if (userBId != null) {
      try {
        await adminClient.request('DELETE', '/users/$userBId');
        print('  ✅ UserB deleted');
      } catch (e) {
        print('  ❌ Could not delete userB: $e');
      }
    }

    adminClient.close();
  }
}

Future<String?> _createSessionForUser(String email, String password) async {
  final uri = Uri.parse('$endpoint/account/sessions/email');
  final client = HttpClient()..badCertificateCallback = (c, h, p) => true;
  final req = await client.postUrl(uri);
  req.headers.set('Content-Type', 'application/json');
  req.headers.set('X-Appwrite-Project', projectId);
  req.write(jsonEncode({'email': email, 'password': password}));
  final resp = await req.close();
  final body = await resp.transform(utf8.decoder).join();
  if (resp.statusCode >= 400) {
    print('    ❌ Session creation failed: $body');
    client.close();
    return null;
  }
  final setCookies = resp.headers['set-cookie'] ?? [];
  if (setCookies.isEmpty) {
    client.close();
    return null;
  }
  // build cookie header string
  final cookiePairs = <String>[];
  for (final sc in setCookies) {
    final pair = sc.split(';').first.trim();
    cookiePairs.add(pair);
  }
  final cookieHeader = cookiePairs.join('; ');
  client.close();
  return cookieHeader;
}

Future<List<dynamic>> _listDocumentsAsUser(String cookieHeader) async {
  final uri = Uri.parse('$endpoint/databases/$databaseId/collections/$biensCollection/documents?limit=1000');
  final client = HttpClient()..badCertificateCallback = (c, h, p) => true;
  final req = await client.getUrl(uri);
  req.headers.set('Content-Type', 'application/json');
  req.headers.set('X-Appwrite-Project', projectId);
  req.headers.set('Cookie', cookieHeader);
  final resp = await req.close();
  final body = await resp.transform(utf8.decoder).join();
  client.close();
  if (resp.statusCode >= 400) {
    throw Exception('HTTP ${resp.statusCode}: $body');
  }
  final decoded = jsonDecode(body) as Map<String, dynamic>;
  return (decoded['documents'] as List<dynamic>?) ?? [];
}

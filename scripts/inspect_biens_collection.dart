// Script: scripts/inspect_biens_collection.dart
// Usage: dart run scripts/inspect_biens_collection.dart
// Affiche la configuration de la collection `biens` (permissions, documentSecurity, etc.)

import 'dart:convert';
import 'dart:io';
import 'setup_appwrite.dart';

final client = AppwriteHttpClient();

Future<void> main() async {
  try {
    final resp = await client.request('GET', '/databases/$databaseId/collections/$biensCollection');
    print(jsonEncode(resp));
  } catch (e) {
    print('Erreur: $e');
  } finally {
    client.close();
  }
}

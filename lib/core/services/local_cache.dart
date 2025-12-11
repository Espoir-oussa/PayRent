import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider générique pour gérer un cache local avec revalidation toutes les 5 minutes.
/// [T] doit être sérialisable en JSON (toJson/fromJson).
class LocalCache<T> {
  final String cacheKey;
  final Future<T> Function() fetcher;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final Duration revalidateDuration;

  LocalCache({
    required this.cacheKey,
    required this.fetcher,
    required this.fromJson,
    required this.toJson,
    this.revalidateDuration = const Duration(minutes: 5),
  });

  Future<T> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheJson = prefs.getString(cacheKey);
    final cacheTime = prefs.getInt('${cacheKey}_time');

    if (cacheJson != null && cacheTime != null) {
      final isFresh = now - cacheTime < revalidateDuration.inMilliseconds;
      if (isFresh) {
        final data = jsonDecode(cacheJson) as Map<String, dynamic>;
        return fromJson(data);
      }
    }

    // Sinon, re-fetch et update le cache
    final freshData = await fetcher();
    await prefs.setString(cacheKey, jsonEncode(toJson(freshData)));
    await prefs.setInt('${cacheKey}_time', now);
    return freshData;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cacheKey);
    await prefs.remove('${cacheKey}_time');
  }
}

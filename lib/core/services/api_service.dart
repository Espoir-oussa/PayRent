// Fichier : lib/core/services/api_service.dart (VERSION CORRIGÉE)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Nécessaire pour kDebugMode

// 1. DÉFINITION DE L'URL DE BASE
// Utilise 10.0.2.2 pour pointer vers le localhost (127.0.0.1) du PC depuis l'émulateur Android.
// Utilise 127.0.0.1 pour les navigateurs web (Flutter Web) ou iOS.
// ⚠️ Si vous testez sur un téléphone physique sur votre réseau Wi-Fi, remplacez-le par votre IP locale (ex: 192.168.1.X).
const String _baseUrl = kDebugMode
  ? 'http://10.0.2.2:8000/api' // URL de l'émulateur vers Laravel
  : 'https://votre-api.com/api'; // URL de production

class ApiService {
  // Stockage du token (géré par le Repository et DI)
  String? _authToken; 

  // Méthode pour définir le token après une connexion réussie
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // En-têtes de base (inclut le token d'authentification)
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      // 🔥 Ajout du Bearer Token pour Laravel
      if (_authToken != null) 'Authorization': 'Bearer $_authToken!', 
    };
  }

  // Requête GET
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Requête POST (Utilisée pour la connexion)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }
  
  // Requête PUT (omis pour l'instant)
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
     final response = await http.put(
       Uri.parse('$_baseUrl/$endpoint'),
       headers: _getHeaders(),
       body: jsonEncode(data),
     );
     return _handleResponse(response);
  }

  // Gestion des erreurs HTTP (mise à jour pour les messages Laravel)
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {}; 
    } else {
      // Pour les erreurs 4xx ou 5xx
      try {
          final errorBody = jsonDecode(response.body);
          // Laravel utilise souvent 'message' ou 'detail'
          final errorMessage = errorBody['message'] ?? errorBody['detail'] ?? 'Erreur inconnue.';
          throw Exception('Erreur API (${response.statusCode}): $errorMessage');
      } catch (_) {
          // Si le corps de la réponse n'est pas un JSON valide
          throw Exception('Échec de la requête: Statut ${response.statusCode}');
      }
    }
  }
}
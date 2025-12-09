
// ===============================
// 🌐 Service : API (Client HTTP)
//
// Ce fichier définit le service centralisé pour les appels HTTP à l'API backend.
//
// Dossier : lib/core/services/
// Rôle : Fournir des méthodes pour effectuer des requêtes réseau (GET, POST, etc.)
// Utilisé par : Repositories, Data Layer
// ===============================

// TODO: Implémenter la classe ApiService
// Exemple de structure :
// class ApiService {
//   final String baseUrl;
//   ApiService(this.baseUrl);
//
//   Future<dynamic> get(String endpoint) async {
//     // ...
//   }
//
//   Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
//     // ...
//   }
//   // ... autres méthodes HTTP
// }




// Fichier : lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// REMPLACER CECI par l'URL de base de votre API Backend (ex: Node.js/Express)
const String _baseUrl = 'https://votre-api.com/api/v1'; 

class ApiService {
  final String? _authToken; // Pour stocker le token JWT après login

  ApiService({String? authToken}) : _authToken = authToken;

  // En-têtes de base (inclut le token d'authentification)
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Requête GET (ex: récupérer la liste des plaintes)
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Requête POST (ex: login, création de plainte)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }
  
  // Requête PUT (ex: mise à jour du statut de plainte)
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Gestion des erreurs HTTP (très simplifié)
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Retourne le JSON décodé ou un objet vide si pas de contenu
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {}; 
    } else {
      // Pour les erreurs 4xx ou 5xx
      final errorBody = jsonDecode(response.body);
      throw Exception('Erreur API (${response.statusCode}): ${errorBody['message']}');
    }
  }
}
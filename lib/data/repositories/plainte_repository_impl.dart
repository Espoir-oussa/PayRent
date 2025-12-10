// Fichier : lib/data/repositories/plainte_repository_impl.dart
// Implémentation Legacy utilisant l'API REST (pour compatibilité)

import '../../core/services/api_service.dart';
import '../../domain/repositories/plainte_repository.dart';
import '../models/plainte_model.dart';


class PlainteRepositoryImpl implements PlainteRepository { 
  final ApiService apiService;

  PlainteRepositoryImpl(this.apiService);

  // === Méthodes Appwrite (délèguent aux méthodes legacy) ===

  @override
  Future<List<PlainteModel>> getPlaintesByProprietaire(String proprietaireId) async {
    return getOwnerComplaints(int.tryParse(proprietaireId) ?? 0);
  }

  @override
  Future<List<PlainteModel>> getPlaintesByLocataire(String locataireId) async {
    // Non implémenté dans l'API legacy
    return [];
  }

  @override
  Future<List<PlainteModel>> getPlaintesByBien(String bienId) async {
    // Non implémenté dans l'API legacy
    return [];
  }

  @override
  Future<PlainteModel> getPlainteById(String plainteId) async {
    throw UnimplementedError('getPlainteById() non implémenté dans la version legacy');
  }

  @override
  Future<PlainteModel> createPlainte(PlainteModel plainte) async {
    return createComplaint(
      locataireId: int.tryParse(plainte.idLocataire) ?? 0,
      sujet: plainte.sujet,
      description: plainte.description,
      bienId: int.tryParse(plainte.idBien) ?? 0,
    );
  }

  @override
  Future<PlainteModel> updatePlainteStatut(String plainteId, String newStatus) async {
    await updateComplaintStatus(
      plainteId: int.tryParse(plainteId) ?? 0,
      newStatus: newStatus,
    );
    // Retourner un modèle vide car l'API legacy ne retourne rien
    throw UnimplementedError('updatePlainteStatut() ne retourne pas de données');
  }

  @override
  Future<PlainteModel> repondrePlainte(String plainteId, String reponse) async {
    throw UnimplementedError('repondrePlainte() non implémenté dans la version legacy');
  }

  @override
  Future<List<PlainteModel>> getPlaintesByStatut(String statut) async {
    // Non implémenté dans l'API legacy
    return [];
  }

  // === Méthodes Legacy ===

  @override
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId) async {
    // Logique d'appel API réelle vers votre Backend
    // final response = await apiService.get('proprietaires/$ownerId/plaintes');
    // return (response as List).map((json) => PlainteModel.fromJson(json)).toList();
    
    // Pour l'instant, on retourne une liste vide pour la compilation :
    return Future.value([]);
  }

  @override
  Future<void> updateComplaintStatus({
    required int plainteId,
    required String newStatus,
  }) async {
    // Logique d'appel API réelle : envoi de la mise à jour via PUT
    await apiService.put(
      'plaintes/$plainteId/status',
      {
        'statut_plainte': newStatus,
      },
    );
  }

  @override
  Future<PlainteModel> createComplaint({
    required int locataireId,
    required String sujet,
    required String description,
    required int bienId,
  }) {
    // Cette méthode est pour la phase 2 (Locataire)
    throw UnimplementedError('createComplaint() n\'est pas encore implémenté.');
  }
}
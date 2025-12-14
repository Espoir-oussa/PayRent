// Fichier : lib/domain/repositories/plainte_repository_impl.dart
// NOTE: Ce fichier devrait être dans lib/data/repositories/
// Implémentation Legacy utilisant l'API REST (pour compatibilité)

import '../../core/services/api_service.dart';
import '../../domain/repositories/plainte_repository.dart';
import '../../data/models/plainte_model.dart';

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
    return [];
  }

  @override
  Future<List<PlainteModel>> getPlaintesByBien(String bienId) async {
    return [];
  }

  @override
  Future<PlainteModel> getPlainteById(String plainteId) async {
    throw UnimplementedError('getPlainteById() non implémenté');
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
    throw UnimplementedError('updatePlainteStatut() ne retourne pas de données');
  }

  @override
  Future<PlainteModel> repondrePlainte(String plainteId, String reponse) async {
    throw UnimplementedError('repondrePlainte() non implémenté');
  }

  @override
  Future<List<PlainteModel>> getPlaintesByStatut(String statut) async {
    return [];
  }

  // === Méthodes Legacy ===

  @override
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId) async {
    final response = await apiService.get('proprietaires/$ownerId/plaintes');
    
    if (response is List) {
      return response.map((json) => PlainteModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> updateComplaintStatus({
    required int plainteId,
    required String newStatus,
  }) async {
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
    throw UnimplementedError('La création de plainte n\'est pas encore implémentée.');
  }
}
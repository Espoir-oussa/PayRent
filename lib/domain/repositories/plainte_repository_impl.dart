// Fichier : lib/data/repositories/plainte_repository_impl.dart

import '../../core/services/api_service.dart';
import '../../domain/repositories/plainte_repository.dart';
import '../../data/models/plainte_model.dart';

class PlainteRepositoryImpl implements PlainteRepository {
  final ApiService apiService;

  PlainteRepositoryImpl(this.apiService);

  @override
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId) async {
    // Supposons que l'API a un endpoint pour récupérer les plaintes par ID de propriétaire
    final response = await apiService.get('proprietaires/$ownerId/plaintes');
    
    // Conversion de la liste JSON en liste de PlainteModel
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
    // Utilise la méthode PUT pour modifier l'enregistrement de la plainte dans le Backend
    await apiService.put(
      'plaintes/$plainteId/status',
      {
        'statut_plainte': newStatus,
      },
    );
    // Le statut 200/204 de la réponse HTTP signifie que la mise à jour est réussie
  }
  
  @override
  Future<PlainteModel> createComplaint({
    required int locataireId,
    required String sujet,
    required String description,
    required int bienId,
  }) {
    // Logique pour la création (pour la phase 2 - Locataire)
    throw UnimplementedError('La création de plainte n\'est pas encore implémentée.');
  }
}
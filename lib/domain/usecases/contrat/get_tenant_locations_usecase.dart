// ===============================
// 📋 Use Case : Get Tenant Locations
// ===============================

import '../../repositories/contrat_repository.dart';
import '../../../data/models/contrat_location_model.dart';

class GetTenantLocationsUseCase {
  final ContratRepository repository;

  GetTenantLocationsUseCase(this.repository);

  /// Récupère tous les contrats actifs du locataire
  Future<List<ContratLocationModel>> call(String locataireId) async {
    return await repository.getContratsByLocataire(locataireId);
  }

  /// Récupère le contrat actif du locataire
  Future<ContratLocationModel?> getActiveContrat(String locataireId) async {
    return await repository.getContratActifByLocataire(locataireId);
  }
}

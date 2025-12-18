// ===============================
// 📝 Use Case : Récupérer les plaintes d'un locataire
// ===============================

import '../../repositories/plainte_repository.dart';
import '../../../data/models/plainte_model.dart';

class GetTenantComplaintsUseCase {
  final PlainteRepository repository;

  GetTenantComplaintsUseCase(this.repository);

  Future<List<PlainteModel>> call(String locataireId) async {
    try {
      return await repository.getPlaintesByLocataire(locataireId);
    } catch (e) {
      return [];
    }
  }
}

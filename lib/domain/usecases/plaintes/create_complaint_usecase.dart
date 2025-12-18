// ===============================
// 📝 Use Case : Créer une plainte
// ===============================

import '../../repositories/plainte_repository.dart';
import '../../../data/models/plainte_model.dart';

class CreateComplaintUseCase {
  final PlainteRepository repository;

  CreateComplaintUseCase(this.repository);

  Future<PlainteModel> call(PlainteModel plainte) async {
    return await repository.createPlainte(plainte);
  }
}

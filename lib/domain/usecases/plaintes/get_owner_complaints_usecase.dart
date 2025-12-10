// ===============================
// 🧩 Use Case : Récupération des plaintes du propriétaire
//
// Ce fichier implémente la logique métier pour récupérer toutes les plaintes
// associées à un propriétaire.
//
// Dossier : lib/domain/usecases/plaintes/
// Rôle : Action métier spécifique (Clean Architecture)
// Utilisé par : Présentation, Repository
// ===============================

import '../../repositories/plainte_repository.dart';
import '../../../data/models/plainte_model.dart';

class GetOwnerComplaintsUseCase {
  final PlainteRepository repository;

  GetOwnerComplaintsUseCase(this.repository);

  Future<List<PlainteModel>> call(int ownerId) async {
    // Appel au repository pour récupérer les plaintes
    return await repository.getOwnerComplaints(ownerId);
  }
}

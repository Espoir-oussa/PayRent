
// ===============================
// 🧩 Use Case : Mise à jour du statut d'une plainte
//
// Ce fichier implémente la logique métier pour changer le statut d'une plainte (Ouverte, Résolue, Fermée).
//
// Dossier : lib/domain/usecases/plaintes/
// Rôle : Action métier spécifique (Clean Architecture)
// Utilisé par : Présentation, Repository
// ===============================

// TODO: Implémenter la classe UpdateComplaintStatusUseCase
// class UpdateComplaintStatusUseCase {
//   // ...
// }



// Fichier : lib/domain/usecases/plaintes/update_complaint_status_usecase.dart

import '../../repositories/plainte_repository.dart';

class UpdateComplaintStatusUseCase {
  final PlainteRepository repository;

  UpdateComplaintStatusUseCase(this.repository);

  // Liste des statuts valides que le Propriétaire peut définir manuellement
  static const List<String> validOwnerStatuses = [
    '2. Réception',             // Accusé de réception
    '3. En Cours de Résolution',
    '4. Résolue',
    '5. Fermée',
  ];

  Future<void> call({
    required int plainteId,
    required String newStatus,
  }) async {
    // 1. Validation de la Logique Métier
    if (!validOwnerStatuses.contains(newStatus)) {
      throw Exception(
          "Statut invalide. Le propriétaire ne peut définir que : ${validOwnerStatuses.join(', ')}");
    }

    // 2. Appel au Repository (indépendant de l'API)
    await repository.updateComplaintStatus(
      plainteId: plainteId,
      newStatus: newStatus,
    );
  }
}
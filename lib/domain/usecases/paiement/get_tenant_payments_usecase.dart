// ===============================
// 📋 Use Case : Get Tenant Payments
// ===============================

import '../../repositories/paiement_repository.dart';
import '../../../data/models/paiement_model.dart';

class GetTenantPaymentsUseCase {
  final PaiementRepository repository;

  GetTenantPaymentsUseCase(this.repository);

  /// Récupère tous les paiements du locataire
  Future<List<PaiementModel>> call(String locataireId) async {
    return await repository.getPaiementsByLocataire(locataireId);
  }

  /// Récupère les paiements d'un contrat
  Future<List<PaiementModel>> getPaymentsByContrat(String contratId) async {
    return await repository.getPaiementsByContrat(contratId);
  }

  /// Récupère les paiements en attente
  Future<List<PaiementModel>> getPendingPayments(String locataireId) async {
    return await repository.getPaiementsByLocataire(locataireId).then(
        (payments) => payments.where((p) => p.statut == 'En attente').toList());
  }
}

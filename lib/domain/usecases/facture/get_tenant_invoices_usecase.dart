// ===============================
// 📋 Use Case : Get Tenant Invoices
// ===============================

import '../../repositories/facture_repository.dart';
import '../../../data/models/facture_model.dart';

class GetTenantInvoicesUseCase {
  final FactureRepository repository;

  GetTenantInvoicesUseCase(this.repository);

  /// Récupère toutes les factures du locataire
  Future<List<FactureModel>> call(String locataireId) async {
    return await repository.getFacturesByLocataire(locataireId);
  }

  /// Récupère les factures par période
  Future<List<FactureModel>> getByPeriode(
    String locataireId,
    DateTime debut,
    DateTime fin,
  ) async {
    return await repository.getFacturesByPeriode(debut, fin);
  }

  /// Récupère l'URL du PDF d'une facture
  Future<String> getPdfUrl(String factureId) async {
    return await repository.getFacturePdfUrl(factureId);
  }
}

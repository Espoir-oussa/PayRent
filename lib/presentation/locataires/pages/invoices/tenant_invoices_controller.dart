// ===============================
// 🎮 Controller : Tenant Invoices
// ===============================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/facture_model.dart';
import '../../../../domain/usecases/facture/get_tenant_invoices_usecase.dart';

enum InvoiceLoadingStatus { idle, loading, success, error }

class TenantInvoicesState {
  final InvoiceLoadingStatus status;
  final List<FactureModel> invoices;
  final String? errorMessage;

  const TenantInvoicesState({
    this.status = InvoiceLoadingStatus.idle,
    this.invoices = const [],
    this.errorMessage,
  });

  TenantInvoicesState copyWith({
    InvoiceLoadingStatus? status,
    List<FactureModel>? invoices,
    String? errorMessage,
  }) {
    return TenantInvoicesState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TenantInvoicesController extends StateNotifier<TenantInvoicesState> {
  final GetTenantInvoicesUseCase _getInvoicesUseCase;

  TenantInvoicesController(this._getInvoicesUseCase)
      : super(const TenantInvoicesState());

  Future<void> loadInvoices(String locataireId) async {
    state = state.copyWith(status: InvoiceLoadingStatus.loading);
    try {
      final invoices = await _getInvoicesUseCase(locataireId);

      state = state.copyWith(
        status: InvoiceLoadingStatus.success,
        invoices: invoices,
      );
    } catch (e) {
      state = state.copyWith(
        status: InvoiceLoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Trier les factures par date (plus récente en premier)
  List<FactureModel> getSortedInvoices() {
    final sorted = List<FactureModel>.from(state.invoices);
    sorted.sort((a, b) => b.dateEmission.compareTo(a.dateEmission));
    return sorted;
  }
}

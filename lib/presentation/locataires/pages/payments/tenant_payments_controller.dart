// ===============================
// 🎮 Controller : Tenant Payments
// ===============================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paiement_model.dart';
import '../../../../domain/usecases/paiement/get_tenant_payments_usecase.dart';

enum PaymentLoadingStatus { idle, loading, success, error }

class TenantPaymentsState {
  final PaymentLoadingStatus status;
  final List<PaiementModel> payments;
  final List<PaiementModel> pendingPayments;
  final String? errorMessage;

  const TenantPaymentsState({
    this.status = PaymentLoadingStatus.idle,
    this.payments = const [],
    this.pendingPayments = const [],
    this.errorMessage,
  });

  TenantPaymentsState copyWith({
    PaymentLoadingStatus? status,
    List<PaiementModel>? payments,
    List<PaiementModel>? pendingPayments,
    String? errorMessage,
  }) {
    return TenantPaymentsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TenantPaymentsController extends StateNotifier<TenantPaymentsState> {
  final GetTenantPaymentsUseCase _getPaymentsUseCase;

  TenantPaymentsController(this._getPaymentsUseCase)
      : super(const TenantPaymentsState());

  Future<void> loadPayments(String locataireId) async {
    state = state.copyWith(status: PaymentLoadingStatus.loading);
    try {
      final payments = await _getPaymentsUseCase(locataireId);
      final pending = await _getPaymentsUseCase.getPendingPayments(locataireId);

      state = state.copyWith(
        status: PaymentLoadingStatus.success,
        payments: payments,
        pendingPayments: pending,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentLoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Trier les paiements par date (plus récent en premier)
  List<PaiementModel> getSortedPayments() {
    final sorted = List<PaiementModel>.from(state.payments);
    sorted.sort((a, b) => b.datePaiement.compareTo(a.datePaiement));
    return sorted;
  }
}

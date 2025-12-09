// ============================================================================
// 📝 EXEMPLE : Comment Implémenter "Historique des Paiements" 
//
// Utilisez ce fichier comme template pour implémenter les autres features
// ============================================================================

// ÉTAPE 1 : CRÉER L'ENTITÉ (Domain Layer)
// Fichier : lib/domain/entities/paiement_entity.dart

/*
class PaiementEntity {
  final int idPaiement;
  final int idContrat;
  final double montantPaye;
  final DateTime datePaiement;
  final String statut; // 'Réussi', 'Échoué', 'En Attente'
  final String? referenceTransaction;

  const PaiementEntity({
    required this.idPaiement,
    required this.idContrat,
    required this.montantPaye,
    required this.datePaiement,
    required this.statut,
    this.referenceTransaction,
  });
}
*/

// ÉTAPE 2 : CRÉER LE REPOSITORY (Domain Layer)
// Fichier : lib/domain/repositories/paiement_repository.dart

/*
import '../entities/paiement_entity.dart';

abstract class PaiementRepository {
  Future<List<PaiementEntity>> getPaiementsByBien(int idBien);
  Future<List<PaiementEntity>> getPaiementsByPeriode(DateTime debut, DateTime fin);
  Future<PaiementEntity> getPaiementById(int idPaiement);
}
*/

// ÉTAPE 3 : CRÉER LE USE CASE (Domain Layer)
// Fichier : lib/domain/usecases/paiements/get_payment_history_usecase.dart

/*
import '../../entities/paiement_entity.dart';
import '../../repositories/paiement_repository.dart';

class GetPaymentHistoryUseCase {
  final PaiementRepository repository;
  GetPaymentHistoryUseCase(this.repository);

  Future<List<PaiementEntity>> call(int idBien) async {
    return await repository.getPaiementsByBien(idBien);
  }
}
*/

// ÉTAPE 4 : CRÉER LE MODEL (Data Layer)
// Fichier : lib/data/models/paiement_model.dart

/*
import '../../domain/entities/paiement_entity.dart';

class PaiementModel extends PaiementEntity {
  PaiementModel({
    required int idPaiement,
    required int idContrat,
    required double montantPaye,
    required DateTime datePaiement,
    required String statut,
    String? referenceTransaction,
  }) : super(
    idPaiement: idPaiement,
    idContrat: idContrat,
    montantPaye: montantPaye,
    datePaiement: datePaiement,
    statut: statut,
    referenceTransaction: referenceTransaction,
  );

  factory PaiementModel.fromJson(Map<String, dynamic> json) {
    return PaiementModel(
      idPaiement: json['id_paiement'],
      idContrat: json['id_contrat'],
      montantPaye: (json['montant_paye'] as num).toDouble(),
      datePaiement: DateTime.parse(json['date_paiement']),
      statut: json['statut'],
      referenceTransaction: json['reference_transaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_contrat': idContrat,
      'montant_paye': montantPaye,
      'date_paiement': datePaiement.toIso8601String(),
      'statut': statut,
      'reference_transaction': referenceTransaction,
    };
  }
}
*/

// ÉTAPE 5 : IMPLÉMENTER LE REPOSITORY (Data Layer)
// Fichier : lib/data/repositories/paiement_repository_impl.dart

/*
import '../../core/services/api_service.dart';
import '../../data/models/paiement_model.dart';
import '../../domain/entities/paiement_entity.dart';
import '../../domain/repositories/paiement_repository.dart';

class PaiementRepositoryImpl implements PaiementRepository {
  final ApiService apiService;

  PaiementRepositoryImpl(this.apiService);

  @override
  Future<List<PaiementEntity>> getPaiementsByBien(int idBien) async {
    try {
      final response = await apiService.get('paiements/bien/$idBien');
      return (response as List)
          .map((p) => PaiementModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<List<PaiementEntity>> getPaiementsByPeriode(DateTime debut, DateTime fin) async {
    try {
      final response = await apiService.get(
        'paiements?debut=${debut.toIso8601String()}&fin=${fin.toIso8601String()}',
      );
      return (response as List)
          .map((p) => PaiementModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  @override
  Future<PaiementEntity> getPaiementById(int idPaiement) async {
    try {
      final response = await apiService.get('paiements/$idPaiement');
      return PaiementModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
*/

// ÉTAPE 6 : AJOUTER LES PROVIDERS (Core - DI)
// Modifiez lib/core/di/providers.dart

/*
// 1. Ajouter les imports
import '../../data/repositories/paiement_repository_impl.dart';
import '../../domain/repositories/paiement_repository.dart';
import '../../domain/usecases/paiements/get_payment_history_usecase.dart';

// 2. Ajouter le provider du repository
final paiementRepositoryProvider = Provider<PaiementRepository>((ref) {
  return PaiementRepositoryImpl(ref.watch(apiServiceProvider));
});

// 3. Ajouter le provider du use case
final getPaymentHistoryUseCaseProvider = Provider((ref) {
  return GetPaymentHistoryUseCase(ref.watch(paiementRepositoryProvider));
});

// 4. Ajouter le provider du controller (next step)
final paymentHistoryControllerProvider = StateNotifierProvider<PaymentHistoryController, PaymentHistoryState>((ref) {
  return PaymentHistoryController(
    getPaymentHistoryUseCase: ref.watch(getPaymentHistoryUseCaseProvider),
  );
});
*/

// ÉTAPE 7 : CRÉER L'ÉTAT (Presentation Layer)
// Fichier : lib/presentation/proprietaires/pages/paiements/payment_history_state.dart

/*
import '../../../../domain/entities/paiement_entity.dart';

enum PaymentHistoryStatus { initial, loading, success, failure }

class PaymentHistoryState {
  final PaymentHistoryStatus status;
  final List<PaiementEntity> paiements;
  final String? errorMessage;

  const PaymentHistoryState({
    this.status = PaymentHistoryStatus.initial,
    this.paiements = const [],
    this.errorMessage,
  });

  PaymentHistoryState copyWith({
    PaymentHistoryStatus? status,
    List<PaiementEntity>? paiements,
    String? errorMessage,
  }) {
    return PaymentHistoryState(
      status: status ?? this.status,
      paiements: paiements ?? this.paiements,
      errorMessage: errorMessage,
    );
  }
}
*/

// ÉTAPE 8 : CRÉER LE CONTROLLER (Presentation Layer)
// Fichier : lib/presentation/proprietaires/pages/paiements/payment_history_controller.dart

/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/paiements/get_payment_history_usecase.dart';
import 'payment_history_state.dart';

class PaymentHistoryController extends StateNotifier<PaymentHistoryState> {
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;

  PaymentHistoryController({required this.getPaymentHistoryUseCase})
      : super(const PaymentHistoryState());

  Future<void> loadPayments(int idBien) async {
    state = state.copyWith(status: PaymentHistoryStatus.loading, errorMessage: null);
    try {
      final paiements = await getPaymentHistoryUseCase(idBien);
      state = state.copyWith(
        status: PaymentHistoryStatus.success,
        paiements: paiements,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentHistoryStatus.failure,
        errorMessage: 'Erreur: ${e.toString()}',
      );
    }
  }
}
*/

// ÉTAPE 9 : CRÉER UN WIDGET RÉUTILISABLE (Presentation Layer)
// Fichier : lib/presentation/proprietaires/widgets/payment_card.dart

/*
import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../domain/entities/paiement_entity.dart';

class PaymentCard extends StatelessWidget {
  final PaiementEntity paiement;
  final VoidCallback? onTap;

  const PaymentCard({
    super.key,
    required this.paiement,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (paiement.statut) {
      case 'Réussi':
        return Colors.green;
      case 'Échoué':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.payment,
          color: _getStatusColor(),
        ),
        title: Text('${paiement.montantPaye.toStringAsFixed(2)} €'),
        subtitle: Text(
          '${paiement.datePaiement.day}/${paiement.datePaiement.month}/${paiement.datePaiement.year}',
        ),
        trailing: Chip(
          label: Text(paiement.statut),
          backgroundColor: _getStatusColor().withOpacity(0.2),
        ),
      ),
    );
  }
}
*/

// ÉTAPE 10 : CRÉER L'ÉCRAN COMPLET (Presentation Layer)
// Modifiez lib/presentation/proprietaires/pages/payment_history_screen.dart

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../widgets/payment_card.dart';
import '../widgets/empty_state_widget.dart';
import 'paiements/payment_history_state.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentHistoryControllerProvider.notifier).loadPayments(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Paiements'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PaymentHistoryState state) {
    if (state.status == PaymentHistoryStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PaymentHistoryStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Erreur'),
            ElevatedButton(
              onPressed: () => ref.read(paymentHistoryControllerProvider.notifier).loadPayments(1),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.paiements.isEmpty) {
      return const EmptyStateWidget(
        title: 'Aucun paiement',
        message: 'Aucun paiement enregistré pour le moment.',
      );
    }

    return ListView.builder(
      itemCount: state.paiements.length,
      itemBuilder: (context, index) {
        return PaymentCard(
          paiement: state.paiements[index],
          onTap: () {
            // TODO: Afficher détails du paiement
          },
        );
      },
    );
  }
}
*/

// ============================================================================
// 🎯 RÉSUMÉ DES 10 ÉTAPES
// ============================================================================
//
// 1. ✅ Entity          (domain/entities/)
// 2. ✅ Repository      (domain/repositories/) - Interface
// 3. ✅ Use Case        (domain/usecases/)
// 4. ✅ Model           (data/models/) - Extends Entity
// 5. ✅ Repository Impl (data/repositories/)
// 6. ✅ Providers       (core/di/providers.dart)
// 7. ✅ State           (presentation/.../)
// 8. ✅ Controller      (presentation/.../)
// 9. ✅ Widget          (presentation/widgets/)
// 10. ✅ Screen         (presentation/pages/)
//
// À chaque fois que vous implémentez une nouvelle feature,
// répétez ces 10 étapes dans cet ordre.
// 
// ============================================================================

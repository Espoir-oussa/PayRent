// Fichier : lib/presentation/proprietaires/pages/bien_screens/bien_list_state.dart

import '../../../../domain/entities/bien_entity.dart';

enum BienStatus { initial, loading, success, failure }

class BienListState {
  final BienStatus status;
  final List<BienEntity> biens;
  final String? errorMessage;

  const BienListState({
    this.status = BienStatus.initial,
    this.biens = const [],
    this.errorMessage,
  });

  BienListState copyWith({
    BienStatus? status,
    List<BienEntity>? biens,
    String? errorMessage,
  }) {
    return BienListState(
      status: status ?? this.status,
      biens: biens ?? this.biens,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
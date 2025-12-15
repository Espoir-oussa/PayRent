// ===============================
// 🎮 Controller : Tenant Locations
// ===============================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/contrat_location_model.dart';
import '../../../../domain/usecases/contrat/get_tenant_locations_usecase.dart';

enum LocationLoadingStatus { idle, loading, success, error }

class TenantLocationsState {
  final LocationLoadingStatus status;
  final List<ContratLocationModel> locations;
  final ContratLocationModel? activeLocation;
  final String? errorMessage;

  const TenantLocationsState({
    this.status = LocationLoadingStatus.idle,
    this.locations = const [],
    this.activeLocation,
    this.errorMessage,
  });

  TenantLocationsState copyWith({
    LocationLoadingStatus? status,
    List<ContratLocationModel>? locations,
    ContratLocationModel? activeLocation,
    String? errorMessage,
  }) {
    return TenantLocationsState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      activeLocation: activeLocation ?? this.activeLocation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TenantLocationsController extends StateNotifier<TenantLocationsState> {
  final GetTenantLocationsUseCase _getLocationsUseCase;

  TenantLocationsController(this._getLocationsUseCase)
      : super(const TenantLocationsState());

  Future<void> loadLocations(String locataireId) async {
    state = state.copyWith(status: LocationLoadingStatus.loading);
    try {
      final locations = await _getLocationsUseCase(locataireId);
      final active = await _getLocationsUseCase.getActiveContrat(locataireId);

      state = state.copyWith(
        status: LocationLoadingStatus.success,
        locations: locations,
        activeLocation: active,
      );
    } catch (e) {
      state = state.copyWith(
        status: LocationLoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void selectLocation(ContratLocationModel location) {
    state = state.copyWith(activeLocation: location);
  }
}

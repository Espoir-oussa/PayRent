import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/owner_register_state.dart';
import '../../../domain/usecases/auth/owner_register_usecase.dart';

class OwnerRegisterController extends StateNotifier<OwnerRegisterState> {
  final OwnerRegisterUseCase registerUseCase;

  OwnerRegisterController({required this.registerUseCase}) : super(OwnerRegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String? telephone,
  }) async {
    state = state.copyWith(status: RegisterStatus.loading, errorMessage: null);
    try {
      final userModel = await registerUseCase(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
      );
      state = state.copyWith(
        status: RegisterStatus.success,
        authToken: userModel.token,
      );
    } catch (e) {
      state = state.copyWith(
        status: RegisterStatus.failure,
        errorMessage: 'Erreur d\'inscription: ${e.toString()}',
      );
    }
  }

  void resetState() {
    state = OwnerRegisterState();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'owner_login_state.dart';
import '../../../../domain/usecases/auth/owner_login_usecase.dart';

class OwnerLoginController extends StateNotifier<OwnerLoginState> {
  final OwnerLoginUseCase loginUseCase;

  OwnerLoginController({required this.loginUseCase}) : super(OwnerLoginState());

  void login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    try {
      final success = await loginUseCase(email, password);
      if (success) {
        state = state.copyWith(
          status: AuthStatus.success,
          isLoading: false,
          email: email,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.failure,
          isLoading: false,
          errorMessage: 'Identifiants incorrects',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() {
    state = OwnerLoginState();
  }
}

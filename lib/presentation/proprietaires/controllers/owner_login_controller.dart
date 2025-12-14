import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/owner_login_state.dart';
import '../../../domain/usecases/auth/owner_login_usecase.dart';

class OwnerLoginController extends StateNotifier<OwnerLoginState> {
  final OwnerLoginUseCase loginUseCase;

  OwnerLoginController({required this.loginUseCase}) : super(OwnerLoginState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: LoginStatus.loading, errorMessage: null);
    try {
      final userModel = await loginUseCase(email: email, password: password);
      state = state.copyWith(
        status: LoginStatus.success,
        authToken: userModel.token,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() {
    state = OwnerLoginState();
  }
}

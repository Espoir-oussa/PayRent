import '../../repositories/auth_repository.dart';

class OwnerLoginUseCase {
  final AuthRepository repository;

  OwnerLoginUseCase(this.repository);

  Future<bool> call(String email, String password) async {
    return await repository.loginOwner(email, password);
  }
}

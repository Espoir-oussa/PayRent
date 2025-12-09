import '../../entities/user_entity.dart'; // Assume this entity exists
import '../../repositories/auth_repository.dart';

class OwnerLoginUseCase {
  final AuthRepository repository;
  OwnerLoginUseCase(this.repository);

  Future<UserEntity> call({required String email, required String password}) async {
    // Le repository implémente les méthodes pour faire l'appel
    return await repository.loginOwner(email: email, password: password);
  }
}
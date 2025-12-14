import '../../../data/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';

class OwnerRegisterUseCase {
  final AuthRepository repository;
  OwnerRegisterUseCase(this.repository);

  Future<UserModel> call({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String? telephone,
  }) {
    return repository.registerOwner(
      email: email,
      password: password,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
    );
  }
}

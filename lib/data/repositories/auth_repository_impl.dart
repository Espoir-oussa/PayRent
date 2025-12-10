import '../../domain/repositories/auth_repository.dart';
import '../../core/services/api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<bool> loginOwner(String email, String password) async {
    // TODO: Implémenter authentification
    return true;
  }

  @override
  Future<void> logout() async {
    // TODO: Implémenter logout
  }
}

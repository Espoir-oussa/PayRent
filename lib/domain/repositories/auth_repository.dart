abstract class AuthRepository {
  Future<bool> loginOwner(String email, String password);
  Future<void> logout();
}

import '../../feature/auth/model/auth_user.dart';

/// Auth işlemleri için soyut kontrat.
/// Implementasyon data/ katmanında yaşar.
/// Notifier bu interface'e bağımlı — somut sınıfa değil.
abstract class IAuthRepository {
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> register(
    String email,
    String password,
    String name, {
    String? lastname,
    String? phone,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<AuthUser?> getCurrentUser();
}

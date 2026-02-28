import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../../feature/auth/model/auth_user.dart';

/// IAuthRepository'nin somut implementasyonu.
/// AuthService'i inject alır — doğrudan new() yapmaz.
class AuthRepositoryImpl implements IAuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AuthUser> signIn(String email, String password) async {
    final response = await _authService.login(email.trim(), password);
    LoggerService.info('AuthRepository.signIn', {
      'success': response.success,
      'statusCode': response.statusCode,
    });
    if (response.success && response.data != null) {
      final data = response.data!;
      return AuthUser(
        id: data.user.id,
        email: data.user.email,
        name: data.user.name,
        lastname: data.user.lastname,
        phone: data.user.phone,
        isEmailVerified: data.user.isEmailVerified,
        createdAt: data.user.createdAt != null
            ? DateTime.tryParse(data.user.createdAt!)
            : null,
        token: data.token,
      );
    }
    throw response.message ?? 'Giriş başarısız';
  }

  @override
  Future<AuthUser> register(
    String email,
    String password,
    String name, {
    String? lastname,
    String? phone,
  }) async {
    final response = await _authService.register(
      email.trim(),
      password,
      name.trim(),
      lastname: lastname?.trim(),
      phone: phone?.trim(),
    );
    if (response.success && response.data != null) {
      final data = response.data!;
      return AuthUser(
        id: data.user.id,
        email: data.user.email,
        name: data.user.name,
        lastname: data.user.lastname,
        phone: data.user.phone,
        isEmailVerified: data.user.isEmailVerified,
        createdAt: data.user.createdAt != null
            ? DateTime.tryParse(data.user.createdAt!)
            : null,
        token: data.token,
      );
    }
    throw response.message ?? 'Kayıt işlemi başarısız';
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _authService.isAuthenticated();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final isAuth = await _authService.isAuthenticated();
    if (!isAuth) return null;
    final response = await _authService.smartGet(
      ApiConstants.me,
      AuthUser.fromJson,
    );
    if (response.success) return response.data;
    return null;
  }
}

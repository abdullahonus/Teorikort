import 'package:driving_license_exam/core/providers/auth_provider.dart';
import 'package:driving_license_exam/core/services/auth_service.dart';
import 'package:driving_license_exam/core/services/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthRepository(authService);
});

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<AuthUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _authService.login(email, password);

      LoggerService.info('Auth Response:', {
        'success': response.success,
        'statusCode': response.statusCode,
        'data': response.data
      });

      if (response.success && response.data != null) {
        final user = AuthUser.fromJson({
          'email': response.data!.user.email,
          'name': response.data!.user.name,
          'lastname': response.data!.user.lastname,
          'phone': response.data!.user.phone,
          'token': response.data!.token,
        });
        return user;
      }

      throw response.message ?? 'Giriş başarısız';
    } catch (e) {
      LoggerService.error('Login Repository Error:', e);
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String name, {
    String? lastname,
    String? phone,
  }) async {
    try {
      final response = await _authService.register(
        email,
        password,
        name,
        lastname: lastname,
        phone: phone,
      );

      if (response.isSuccess) {
        return {
          'user': response.data!.user.toJson(),
          'token': response.data!.token,
        };
      }

      throw response.message ?? 'Kayıt işlemi başarısız';
    } catch (e) {
      LoggerService.error('Register Error:', e);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}

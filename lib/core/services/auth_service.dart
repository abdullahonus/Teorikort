import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_tokens.dart';
import '../models/password_validation_response.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  final _storage = FlutterSecureStorage();

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _tokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<AuthTokens?> getTokens() async {
    final accessToken = await _storage.read(key: _tokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    return null;
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> isAuthenticated() async {
    final tokens = await getTokens();
    return tokens != null;
  }

  Future<PasswordValidationResponse> validatePassword(String password) async {
    // TODO: API entegrasyonu eklenecek
    await Future.delayed(const Duration(milliseconds: 500));

    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    List<String> errors = [];

    if (password.length >= 8) strength += 25;
    if (hasUpperCase) strength += 25;
    if (hasLowerCase) strength += 25;
    if (hasDigit) strength += 15;
    if (hasSpecialChar) strength += 10;

    if (!hasUpperCase) errors.add('Büyük harf gerekli');
    if (!hasLowerCase) errors.add('Küçük harf gerekli');
    if (!hasDigit) errors.add('Rakam gerekli');

    return PasswordValidationResponse(
      isValid: strength >= 70,
      strength: strength,
      validationErrors: errors,
    );
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    // TODO: API entegrasyonu eklenecek
    await Future.delayed(const Duration(seconds: 2));
    // Simüle edilmiş başarılı yanıt
  }
}

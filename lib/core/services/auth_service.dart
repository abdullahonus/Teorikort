import 'package:driving_license_exam/core/constants/api_constants.dart';
import 'package:driving_license_exam/core/models/api_response.dart';
import 'package:driving_license_exam/core/models/auth_response.dart';
import 'package:driving_license_exam/core/models/auth_tokens.dart';
import 'package:driving_license_exam/core/models/password_validation_response.dart';
import 'package:driving_license_exam/core/services/logger_service.dart';
import 'package:driving_license_exam/core/services/base_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends BaseApiService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  AuthService() : _storage = const FlutterSecureStorage();

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _tokenKey, value: tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken!);
    }
  }

  Future<AuthTokens?> getTokens() async {
    final accessToken = await _storage.read(key: _tokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken != null) {
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
    return await _storage.read(key: _tokenKey) != null;
  }

  Future<PasswordValidationResponse> validatePassword(String password) async {
    // Password validation logic (no API call needed)
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

  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    return await handleResponse<AuthResponse>(
      post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      ),
      (json) {
        final userData =
            UserData.fromJson(json['user'] as Map<String, dynamic>);
        final token = json['token'] as String;

        // Save token automatically
        saveTokens(AuthTokens(accessToken: token));

        return AuthResponse(
          token: token,
          user: userData,
        );
      },
    );
  }

  Future<ApiResponse<AuthResponse>> register(
    String email,
    String password,
    String name, {
    String? lastname,
    String? phone,
  }) async {
    return await handleResponse<AuthResponse>(
      post(
        ApiConstants.register,
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
          if (lastname?.isNotEmpty == true) 'lastname': lastname!.trim(),
          if (phone?.isNotEmpty == true) 'phone': phone!.trim(),
        },
      ),
      (json) {
        final userData =
            UserData.fromJson(json['user'] as Map<String, dynamic>);
        final token = json['token'] as String;

        // Save token automatically
        saveTokens(AuthTokens(accessToken: token));

        return AuthResponse(
          token: token,
          user: userData,
        );
      },
    );
  }

  Future<ApiResponse<void>> sendOTP(String email) async {
    return await handleResponse<void>(
      post(
        ApiConstants.sendOtp,
        data: {'email': email.trim()},
      ),
      (json) => null, // No data needed for OTP send
    );
  }

  Future<ApiResponse<void>> verifyOTP(String email, String otp) async {
    return await handleResponse<void>(
      post(
        ApiConstants.verifyOtp,
        data: {
          'email': email.trim(),
          'otp': otp,
        },
      ),
      (json) => null, // No data needed for OTP verification
    );
  }

  Future<ApiResponse<void>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    return await handleResponse<void>(
      post(
        ApiConstants.resetPassword,
        data: {
          'email': email.trim(),
          'otp': otp,
          'new_password': newPassword,
        },
      ),
      (json) => null, // No data needed for password reset
    );
  }

  Future<void> logout() async {
    try {
      // Optionally call logout endpoint
      // await post(ApiConstants.logout);

      // Always clear local tokens
      await deleteTokens();
    } catch (e) {
      LoggerService.error('Logout error:', e);
      // Still clear tokens even if API call fails
      await deleteTokens();
    }
  }
}

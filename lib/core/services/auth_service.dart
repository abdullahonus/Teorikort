import 'package:driving_license_exam/core/constants/api_constants.dart';
import 'package:driving_license_exam/core/models/api_response.dart';
import 'package:driving_license_exam/core/models/auth_response.dart';
import 'package:driving_license_exam/core/models/auth_tokens.dart';
import 'package:driving_license_exam/core/models/password_validation_response.dart';
import 'package:driving_license_exam/core/services/logger_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthService()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: ApiConstants.headers,
        )),
        _storage = const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        LoggerService.info('API Request:', {
          'url': options.uri.toString(),
          'method': options.method,
          'data': options.data,
        });
        return handler.next(options);
      },
      onResponse: (response, handler) {
        LoggerService.info('API Response:', {
          'statusCode': response.statusCode,
          'data': response.data,
        });
        return handler.next(response);
      },
      onError: (error, handler) {
        LoggerService.error('API Error:', error.response?.data);
        return handler.next(error);
      },
    ));
  }

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
    return await _storage.read(key: _tokenKey) != null;
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

  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(validateStatus: (_) => true),
      );

      LoggerService.info('Login Response:', response.data);

      if (response.statusCode != 200) {
        return ApiResponse<AuthResponse>(
          success: false,
          message: _getErrorMessage(response.statusCode),
          statusCode: response.statusCode ?? 500,
        );
      }

      // API yanıt yapısına göre düzeltildi
      final userData = UserData.fromJson(
          response.data['data']['user'] as Map<String, dynamic>);
      final token = response.data['data']['token'] as String;

      await saveTokens(AuthTokens(accessToken: token));

      return ApiResponse<AuthResponse>(
        statusCode: 200,
        success: true,
        data: AuthResponse(
          token: token,
          user: userData,
        ),
      );
    } catch (e) {
      LoggerService.error('Login Service Error:', e);
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Bir hata oluştu. Lütfen tekrar deneyin',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<AuthResponse>> register(
    String email,
    String password,
    String name, {
    String? lastname,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
          if (lastname?.isNotEmpty == true) 'lastname': lastname!.trim(),
          if (phone?.isNotEmpty == true) 'phone': phone!.trim(),
        },
        options: Options(validateStatus: (_) => true),
      );

      LoggerService.info('Register Response:', response.data);

      // Başarısız yanıtları kontrol et
      if (response.statusCode != 200) {
        return ApiResponse<AuthResponse>(
          success: false,
          // Önce API'den gelen özel hata mesajını kontrol et, yoksa genel hata mesajını kullan
          message:
              response.data['error'] ?? _getErrorMessage(response.statusCode),
          statusCode: response.statusCode ?? 500,
        );
      }

      final userData = UserData.fromJson(
          response.data['data']['user'] as Map<String, dynamic>);
      final token = response.data['data']['token'] as String;

      await saveTokens(AuthTokens(accessToken: token));

      return ApiResponse<AuthResponse>(
        statusCode: 200,
        success: true,
        data: AuthResponse(
          token: token,
          user: userData,
        ),
      );
    } catch (e) {
      LoggerService.error('Register Service Error:', e);
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Bir hata oluştu. Lütfen tekrar deneyin',
        statusCode: 500,
      );
    }
  }

  String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz bilgiler girildi';
      case 401:
        return 'E-posta veya şifre hatalı';
      case 409:
        return 'Bu e-posta adresi zaten kayıtlı';
      case 422:
        return 'Eksik veya hatalı bilgi girişi';
      case 429:
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}

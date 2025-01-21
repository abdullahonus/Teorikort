import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/auth_tokens.dart';
import '../../features/auth/data/models/auth_user.dart';
import '../services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated) {
      // TODO: Fetch user data from API
      state = AuthState.authenticated(AuthUser(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: null,
        isEmailVerified: true,
      ));
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      // TODO: Call actual API
      await Future.delayed(const Duration(seconds: 2));

      // Simüle edilmiş hata durumları
      if (email == 'timeout@test.com') {
        throw TimeoutException();
      } else if (email == 'server@test.com') {
        throw ServerException();
      }

      final tokens = AuthTokens(
        accessToken: 'fake_access_token',
        refreshToken: 'fake_refresh_token',
      );

      LoggerService.info('User logged in successfully: $email');
      await _authService.saveTokens(tokens);
      state = AuthState.authenticated(AuthUser(
        id: '1',
        email: email,
        name: 'Test User',
        createdAt: null,
        isEmailVerified: true,
      ));
    } catch (e) {
      LoggerService.error('Login failed', e);
      String errorMessage;

      if (e is TimeoutException) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e is ServerException) {
        errorMessage = 'Server error occurred. Please try again later.';
      } else {
        errorMessage = 'An unexpected error occurred.';
      }

      state = AuthState.error(errorMessage);
    }
  }

  Future<void> signOut() async {
    await _authService.deleteTokens();
    state = const AuthState.unauthenticated();
  }

  Future<void> sendOTP(String email) async {
    try {
      state = const AuthState.loading();
      // TODO: Call actual API
      await Future.delayed(const Duration(seconds: 2));

      LoggerService.info('OTP sent to: $email');
      state = const AuthState.unauthenticated();
    } catch (e) {
      LoggerService.error('Failed to send OTP', e);
      state = AuthState.error('Failed to send verification code');
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    try {
      state = const AuthState.loading();
      // TODO: Call actual API
      await Future.delayed(const Duration(seconds: 2));

      if (otp == '123456') {
        // Test OTP
        LoggerService.info('OTP verified for: $email');
        state = const AuthState.unauthenticated();
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      LoggerService.error('OTP verification failed', e);
      state = AuthState.error('Invalid verification code');
    }
  }
}

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  const AuthState.initial()
      : user = null,
        isLoading = true,
        error = null;

  const AuthState.authenticated(AuthUser this.user)
      : isLoading = false,
        error = null;

  const AuthState.unauthenticated()
      : user = null,
        isLoading = false,
        error = null;

  const AuthState.loading()
      : user = null,
        isLoading = true,
        error = null;

  const AuthState.error(String this.error)
      : user = null,
        isLoading = false;
}

class TimeoutException implements Exception {}

class ServerException implements Exception {}

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

import 'package:teorikort/core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/auth_tokens.dart';
import '../../features/auth/data/models/auth_user.dart';
import '../services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';
import '../../features/user/domain/models/user_profile.dart';

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
      try {
        // fetch current user info from actual /me endpoint
        final apiResponse = await _authService.smartGet(
          ApiConstants.me,
          (json) => AuthUser.fromJson(json),
        );
        if (apiResponse.success && apiResponse.data != null) {
          final authUser = apiResponse.data!;
          await UserService().updateUserFromApi(UserProfile(
            id: authUser.id.toString(),
            name: authUser.name,
            email: authUser.email,
            lastname: authUser.lastname,
            phone: authUser.phone,
            createdAt: authUser.createdAt?.toIso8601String(),
          ));
          state = AuthState.authenticated(authUser);
        } else {
          state = const AuthState.unauthenticated();
        }
      } catch (e) {
        state = const AuthState.unauthenticated();
      }
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      final apiResponse = await _authService.login(email, password);

      if (apiResponse.success && apiResponse.data != null) {
        final userData = apiResponse.data!.user;
        final token = apiResponse.data!.token;

        await _authService.saveTokens(AuthTokens(accessToken: token));

        state = AuthState.authenticated(AuthUser(
          id: userData.id,
          email: userData.email,
          name: userData.name,
          lastname: userData.lastname,
          phone: userData.phone,
          isEmailVerified: userData.isEmailVerified,
          createdAt: userData.createdAt != null
              ? DateTime.parse(userData.createdAt!)
              : null,
          token: token,
        ));

        await UserService().updateUserFromApi(UserProfile(
          id: userData.id.toString(),
          name: userData.name,
          email: userData.email,
          lastname: userData.lastname,
          phone: userData.phone,
          createdAt: userData.createdAt,
        ));

        LoggerService.info('User logged in successfully: $email');
      } else {
        throw apiResponse.message ?? 'Giriş başarısız';
      }
    } catch (e) {
      LoggerService.error('Login failed', e);
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.logout();
    } finally {
      await UserService().clearUserData();
      state = const AuthState.unauthenticated();
    }
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

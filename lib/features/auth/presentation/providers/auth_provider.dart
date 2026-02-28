import 'dart:developer';

import 'package:teorikort/core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../models/user_model.dart';
import '../../../../core/services/logger_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? token;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.token,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? token,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      if (!email.contains('@') || !email.contains('.')) {
        throw 'Geçersiz e-posta formatı';
      }

      final response =
          await _repository.signInWithEmailAndPassword(email, password);

      if (response != null) {
        state = state.copyWith(
          isLoading: false,
          user: UserModel.fromAuthUser(response),
          token: response.token,
          error: null,
        );
        LoggerService.info('SignIn Successful: ${state.user?.toJson()}');
      } else {
        throw 'Giriş başarısız';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        user: null,
        token: null,
      );
    }
  }

  Future<void> signUp(String email, String password, String name,
      {String? lastname, String? phone}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Email formatı kontrolü
      if (!email.contains('@') || !email.contains('.')) {
        throw 'Geçersiz e-posta formatı';
      }

      // Şifre kontrolü
      if (password.length < 6) {
        throw 'Şifre en az 6 karakter olmalıdır';
      }

      final response = await _repository.register(
        email,
        password,
        name,
        lastname: lastname,
        phone: phone,
      );

      LoggerService.info('SignUp Response: $response');

      if (response != null && response['user'] is Map<String, dynamic>) {
        final userData = response['user'] as Map<String, dynamic>;
        final token = response['token'] as String?;

        state = state.copyWith(
          isLoading: false,
          user: UserModel.fromJson(userData),
          token: token,
          error: null,
        );
        LoggerService.info('SignUp Successful: ${state.user?.toJson()}');
      } else {
        throw 'Kayıt işlemi başarısız';
      }
    } catch (e) {
      LoggerService.error('SignUp Error:', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();

      state = const AuthState(
        user: null,
        token: null,
        isLoading: false,
        error: null,
      );

      LoggerService.info('User logged out successfully');
    } catch (e) {
      LoggerService.error('Logout Error:', e);
      state = state.copyWith(
        error: 'Çıkış yapılırken bir hata oluştu',
      );
    }
  }

/*   Future<void> sendOTP(String email) async {
    state = const AuthState.loading();
    try {
      await _authService.sendOTP(email);
      state = const AuthState.otpSent();
    } catch (e) {
      state = AuthState.error!(e.toString());
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    state = const AuthState.loading();
    try {
      final isValid = await _authService.verifyOTP(email, otp);
      if (isValid) {
        state = const AuthState.otpVerified();
      } else {
        state = const AuthState.error('Invalid OTP');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  } */
}

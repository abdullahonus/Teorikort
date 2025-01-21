import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.unauthenticated());

  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user =
          await _repository.signInWithEmailAndPassword(email, password);
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.error('Invalid credentials');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.signUpWithEmailAndPassword(
        email,
        password,
        name,
      );
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.error('Registration failed');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendOTP(String email) async {
    state = const AuthState.loading();
    try {
      await _repository.sendOTP(email);
      state = const AuthState.otpSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    state = const AuthState.loading();
    try {
      final isValid = await _repository.verifyOTP(email, otp);
      if (isValid) {
        state = const AuthState.otpVerified();
      } else {
        state = const AuthState.error('Invalid OTP');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  final bool isOtpSent;
  final bool isOtpVerified;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
    this.isOtpVerified = false,
  });

  const AuthState.unauthenticated()
      : user = null,
        isLoading = false,
        error = null,
        isOtpSent = false,
        isOtpVerified = false;

  const AuthState.authenticated(AuthUser this.user)
      : isLoading = false,
        error = null,
        isOtpSent = false,
        isOtpVerified = false;

  const AuthState.loading()
      : user = null,
        isLoading = true,
        error = null,
        isOtpSent = false,
        isOtpVerified = false;

  const AuthState.error(String this.error)
      : user = null,
        isLoading = false,
        isOtpSent = false,
        isOtpVerified = false;

  const AuthState.otpSent()
      : user = null,
        isLoading = false,
        error = null,
        isOtpSent = true,
        isOtpVerified = false;

  const AuthState.otpVerified()
      : user = null,
        isLoading = false,
        error = null,
        isOtpSent = true,
        isOtpVerified = true;
}

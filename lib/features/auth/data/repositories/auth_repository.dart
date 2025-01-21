import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<AuthUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return AuthUser(
      id: '1',
      email: email,
      name: 'Test User',
      createdAt: DateTime.now(),
      isEmailVerified: true,
    );
  }

  Future<AuthUser?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return AuthUser(
      id: '1',
      email: email,
      name: name,
      createdAt: DateTime.now(),
      isEmailVerified: false,
    );
  }

  Future<void> sendOTP(String email) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
  }

  Future<bool> verifyOTP(String email, String otp) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return true;
  }

  Future<void> resetPassword(String email) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
  }
}

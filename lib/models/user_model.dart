import 'package:driving_license_exam/features/auth/data/models/auth_user.dart';

class UserModel {
  final String email;
  final String name;
  final String? phone;
  final bool isEmailVerified;

  UserModel({
    required this.email,
    required this.name,
    this.phone,
    this.isEmailVerified = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      isEmailVerified: json['is_email_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'is_email_verified': isEmailVerified,
    };
  }

  // Conversion method
  factory UserModel.fromAuthUser(AuthUser authUser) {
    return UserModel(
      email: authUser.email,
      name: authUser.name,
      phone: authUser.phone,
      isEmailVerified: authUser.isEmailVerified,
    );
  }
}

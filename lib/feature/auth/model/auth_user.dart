import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? lastname;
  final String? phone;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String? token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.lastname,
    this.phone,
    this.photoUrl,
    this.createdAt,
    required this.isEmailVerified,
    this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastname: json['lastname'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'lastname': lastname,
        'phone': phone,
        'photo_url': photoUrl,
        'created_at': createdAt?.toIso8601String(),
        'is_email_verified': isEmailVerified,
        'token': token,
      };

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        lastname,
        phone,
        photoUrl,
        createdAt,
        isEmailVerified,
        token
      ];
}

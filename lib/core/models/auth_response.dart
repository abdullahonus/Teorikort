class AuthResponse {
  final UserData user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponse(
        user: UserData.fromJson(json['user'] as Map<String, dynamic>),
        token: json['token'] as String,
      );
    } catch (e) {
      throw FormatException('Invalid auth response format: $json');
    }
  }
}

class UserData {
  final int id;
  final String email;
  final String name;
  final String? lastname;
  final String? phone;
  final bool isEmailVerified;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.lastname,
    this.phone,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    try {
      return UserData(
        id: json['id'] as int? ?? 0,
        email: json['email'] as String,
        name: json['name'] as String,
        lastname: json['lastname'] as String?,
        phone: json['phone'] as String?,
        isEmailVerified: json['is_email_verified'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );
    } catch (e) {
      throw FormatException('Invalid user data format: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

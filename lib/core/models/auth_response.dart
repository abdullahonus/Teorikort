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
  final String email;
  final String name;
  final String? lastname;
  final String? phone;
  final String createdAt;
  final String updatedAt;

  UserData({
    required this.email,
    required this.name,
    this.lastname,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    try {
      return UserData(
        email: json['email'] as String,
        name: json['name'] as String,
        lastname: json['lastname'] as String?,
        phone: json['phone'] as String?,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );
    } catch (e) {
      throw FormatException('Invalid user data format: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

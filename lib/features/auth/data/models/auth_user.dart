class AuthUser {
  final String email;
  final String name;
  final String? lastname;
  final String? phone;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String? token;

  AuthUser({
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
      email: json['email'],
      name: json['name'],
      lastname: json['lastname'],
      phone: json['phone'],
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isEmailVerified: json['is_email_verified'] ?? false,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'photo_url': photoUrl,
      'created_at': createdAt!.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'token': token,
    };
  }
}

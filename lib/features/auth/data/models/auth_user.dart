class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isEmailVerified;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.createdAt,
    required this.isEmailVerified,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isEmailVerified: json['is_email_verified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'created_at': createdAt!.toIso8601String(),
      'is_email_verified': isEmailVerified,
    };
  }
}

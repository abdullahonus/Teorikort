class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? lastname;
  final String? phone;
  final int? package;
  final String? createDate;
  final String? createdAt;
  final String? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.lastname,
    this.phone,
    this.package,
    this.createDate,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      lastname: json['lastname'],
      phone: json['phone'],
      package: json['package'],
      createDate: json['create_date']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String get fullName => lastname != null ? '$name $lastname' : name;
}

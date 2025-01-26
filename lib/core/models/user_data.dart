class UserData {
  final String email;
  final String name;
  final String? lastname;
  final String? phone;

  UserData({
    required this.email,
    required this.name,
    this.lastname,
    this.phone,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      email: json['email'] as String,
      name: json['name'] as String,
      lastname: json['lastname'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'lastname': lastname,
      'phone': phone,
    };
  }
}

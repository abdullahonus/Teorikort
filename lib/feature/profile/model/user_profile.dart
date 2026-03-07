import 'package:equatable/equatable.dart';

/// Spec STATE MODEL PATTERN — Equatable + copyWith
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? lastname;
  final String? phone;
  final int? package;
  final String? createDate;
  final String? createdAt;
  final String? updatedAt;
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.lastname,
    this.phone,
    this.package,
    this.createDate,
    this.createdAt,
    this.updatedAt,
    this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      lastname: json['lastname'] as String?,
      phone: json['phone'] as String?,
      package: json['package'] as int?,
      createDate: json['create_date']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'lastname': lastname,
        'phone': phone,
        'package': package,
        'create_date': createDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'photo_url': photoUrl,
      };

  String get fullName =>
      lastname != null && lastname!.isNotEmpty ? '$name $lastname' : name;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? lastname,
    String? phone,
    int? package,
    String? createDate,
    String? createdAt,
    String? updatedAt,
    String? photoUrl,
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        lastname: lastname ?? this.lastname,
        phone: phone ?? this.phone,
        package: package ?? this.package,
        createDate: createDate ?? this.createDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        lastname,
        phone,
        package,
        createDate,
        createdAt,
        updatedAt,
        photoUrl
      ];
}

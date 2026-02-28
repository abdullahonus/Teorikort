import 'package:shared_preferences/shared_preferences.dart';
import '../../features/user/domain/models/user_profile.dart';
import 'dart:convert';

class UserService {
  static final UserService _instance = UserService._internal();
  static bool _initialized = false;

  factory UserService() => _instance;

  UserService._internal() {
    if (!_initialized) {
      _initialized = true;
      initializeService();
    }
  }

  // API'den gelen kullanıcı bilgilerini tutacak map
  Map<String, dynamic> currentUser = {};

  String get currentUserId => currentUser['id']?.toString() ?? '';

  String get currentUserName {
    final name = currentUser['name'] as String?;
    final lastname = currentUser['lastname'] as String?;
    if (name != null) {
      return lastname != null ? '$name $lastname' : name;
    }
    return '';
  }

  String get currentUserPhoto =>
      currentUser['photo_url'] ??
      'https://xsgames.co/randomusers/assets/avatars/male/8.jpg'; // varsayılan avatar

  String get currentUserFirstName {
    final name = currentUser['name'] as String?;
    return name?.split(' ').first ?? '';
  }

  Future<void> initializeService() async {
    final prefs = await SharedPreferences.getInstance();

    // Kaydedilmiş kullanıcı bilgilerini yükle
    final savedUserData = prefs.getString('user_data');
    if (savedUserData != null) {
      currentUser = Map<String, dynamic>.from(json.decode(savedUserData));
    }
  }

  // API'den gelen kullanıcı bilgilerini güncelle
  Future<void> updateUserFromApi(UserProfile profile) async {
    currentUser = {
      'id': profile.id,
      'name': profile.name,
      'lastname': profile.lastname,
      'email': profile.email,
      'phone': profile.phone,
      'package': profile.package,
      'created_at': profile.createdAt,
    };

    // Kullanıcı bilgilerini local'e kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(currentUser));
  }

  Future<void> updateUserName(String newName) async {
    currentUser['name'] = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(currentUser));
  }

  Future<void> updateUserPhoto(String newPhotoUrl) async {
    currentUser['photo_url'] = newPhotoUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(currentUser));
  }

  Future<void> updateLastExamScore(int score) async {
    currentUser['last_score'] = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(currentUser));
  }

  int getLastExamScore() {
    return currentUser['last_score'] ?? 0;
  }

  // Kullanıcı oturumunu temizle
  Future<void> clearUserData() async {
    currentUser.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}

import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> currentUser = {
    'id': 'current_user',
    'name': 'Emre Yılmaz',
    'photo_url': 'https://xsgames.co/randomusers/assets/avatars/male/8.jpg',
  };

  String get currentUserId => currentUser['id'];
  String get currentUserName => currentUser['name'];
  String get currentUserPhoto => currentUser['photo_url'];

  String get currentUserFirstName {
    final fullName = currentUser['name'] as String;
    return fullName.split(' ').first;
  }

  Future<void> initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    final savedPhoto = prefs.getString('user_photo');

    if (savedName != null) {
      currentUser['name'] = savedName;
    } else {
      // İlk kez çalıştığında varsayılan ismi kaydet
      await prefs.setString('user_name', currentUser['name']);
    }

    if (savedPhoto != null) {
      currentUser['photo_url'] = savedPhoto;
    } else {
      // İlk kez çalıştığında varsayılan fotoğrafı kaydet
      await prefs.setString('user_photo', currentUser['photo_url']);
    }
  }

  Future<void> updateUserName(String newName) async {
    currentUser['name'] = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
  }

  Future<void> updateUserPhoto(String newPhotoUrl) async {
    currentUser['photo_url'] = newPhotoUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo', newPhotoUrl);
  }

  Future<void> updateLastExamScore(int score) async {
    currentUser['last_score'] = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_score', score);
  }

  int getLastExamScore() {
    return currentUser['last_score'] ?? 0;
  }
}

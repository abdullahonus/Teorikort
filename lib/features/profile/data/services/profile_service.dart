import 'package:teorikort/core/services/json_service.dart';
import '../models/profile_data.dart';

class ProfileService {
  Future<ProfileData> getProfileData() async {
    final json = await JsonService.getProfileData();
    return ProfileData.fromJson(json);
  }
}

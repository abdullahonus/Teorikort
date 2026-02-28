import '../../../core/models/api_response.dart';
import 'package:teorikort/feature/profile/model/user_profile.dart';

/// Profile/user işlemleri için soyut kontrat.
abstract class IProfileRepository {
  Future<ApiResponse<UserProfile>> getUserProfile();
  Future<ApiResponse<UserProfile>> updateUserProfile(String name);
}

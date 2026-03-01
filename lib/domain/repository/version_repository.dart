import '../../core/models/api_response.dart';
import '../../data/splash_response_model.dart';

abstract class IVersionRepository {
  Future<ApiResponse<SplashResponseModel>> getAppVersion();
}

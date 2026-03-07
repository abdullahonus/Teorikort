import '../../../core/constants/api_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/base_api_service.dart';
import '../../../data/splash_response_model.dart';

class VersionService extends BaseApiService {
  Future<ApiResponse<SplashResponseModel>> getSplashData() async {
    return handleResponse<SplashResponseModel>(
      get(ApiConstants.splash),
      (json) => SplashResponseModel.fromJson(json),
    );
  }
}

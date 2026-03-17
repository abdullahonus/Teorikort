import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/about_model.dart';

class AboutService extends BaseApiService {
  Future<ApiResponse<AboutModel>> getAbout() async {
    return await handleResponse<AboutModel>(
      get(ApiConstants.aboutUs),
      AboutModel.fromJson,
    );
  }
}

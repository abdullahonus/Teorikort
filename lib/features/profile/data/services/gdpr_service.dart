import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/gdpr_model.dart';

class GDPRService extends BaseApiService {
  Future<ApiResponse<GDPRModel>> getGDPR() async {
    return await handleResponse<GDPRModel>(
      get(ApiConstants.gdpr),
      GDPRModel.fromJson,
    );
  }
}
